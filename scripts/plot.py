#!/usr/bin/python3

import matplotlib, matplotlib.pyplot as plt
import json
import datetime

deposit = '0xa945e51eec50ab98c161376f0db4cf2aeba3ec92755fe2fcd388bdbbb80ff196'
withdraw = '0xe9e508bad6d4c3227e881ca19068f099da81b5164dd6d62b2eaf1e8bc6c34931'
interest = 0.02 / 365 / 24 / 60 / 60

with open('events-10.json') as f:
    data = json.load(f)

timestamps = [int(x['timeStamp'], 16) for x in data]
balances = []
profits = [0]

balance = 0
for i, event in enumerate(data):
    if event['topics'][0] == deposit:
        balance += 10
    elif event['topics'][0] == withdraw:
        balance -= 10
    balances.append(balance);
    if i > 0:
        profits.append(profits[i-1] + (balance * interest * (timestamps[i] - timestamps[i - 1])))

timestamps = [datetime.datetime.fromtimestamp(x) for x in timestamps]

matplotlib.rc('font', size=16)

fig, ax1 = plt.subplots()
color = 'tab:red'
ax1.set_xlabel('час')
ax1.set_ylabel('баланс контракту', color=color)
ax1.plot(timestamps, balances, color=color)
ax1.tick_params(axis='y', labelcolor=color)

ax2 = ax1.twinx()
color = 'tab:blue'
ax2.set_ylabel('прибутки від вкладень в Aave', color=color)
ax2.plot(timestamps, profits, color=color)
ax2.tick_params(axis='y', labelcolor=color)

fig.tight_layout()
plt.show()

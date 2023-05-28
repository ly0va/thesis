#let fontsize = 14pt
#show heading: set text(size: fontsize)
#show heading.where(level: 1): it => align(center)[ #upper(it) \ ]
#set text(size: fontsize, font: "Noto Serif", lang: "ua")
#show raw: set text(size: fontsize)
#show math.equation: set text(size: 16pt) // for some reason it looks smaller
#set page(
  paper: "a4",
  margin: (
    top: 20mm,
    bottom: 20mm,
    left: 25mm,
    right: 10mm
  ),
  header: align(right)[#counter(page).display(i => if i != 1 [#i])]
)

#align(center)[
  *КИЇВСЬКИЙ НАЦІОНАЛЬНИЙ УНІВЕРСИТЕТ \
  ІМЕНІ ТАРАСА ШЕВЧЕНКА* \
  #text(size: 12pt)[
    Факультет комп’ютерних наук та кібернетики \
    Кафедра математичної інформатики
  ] \ \
  *Кваліфікаційна робота \
  на здобуття ступеня бакалавра* \
  #text(size: 12pt)[
    за освітньо-професійною програмою “Інформатика” \
    спеціальності 122 Комп'ютерні науки на тему:
  ] \ \
  *РЕАЛІЗАЦІЯ ПРОТОКОЛУ АНОНІМНИХ ПЕРЕКАЗІВ \
  НА ОСНОВІ ДОКАЗІВ З НУЛЬОВИМ РОЗГОЛОШЕННЯМ* \ \
]

#let signature = [
  \
  #line(length: 100%)
  #align(center, text(size: 0.8em, "(підпис)"))
]

#grid(
  columns: (70%, 30%),
  [
    Виконав студент 4-го курсу \
    Потьомкін Лев Євгенович
  ],
  signature,
  [
    Науковий керівник: \
    Член-кореспондент НАН України, професор \
    Анісімов Анатолій Васильович
  ],
  [\ #signature],
)

\
#text(size: 12pt)[
  #grid(
    columns: (40%, 60%),
    [],
    [
      Засвідчую, що в цій роботі немає запозичень з
      праць інших авторів без відповідних посилань.

      #grid(
        columns: (50%, 50%),
        align(center)[\ Студент],
        signature,
      )
    ],
    [],
    [
      \ \
      Роботу розглянуто й допущено до захисту
      на засіданні кафедри математичної інформатики
      \

      #grid(
        columns: (30%, 12%, 8%, 35%, 15%),
        [Протокол №],
        [#v(0.8em) #line(length: 90%)],
        [],
        [#v(0.8em) #line(length: 90%)],
        [2023 р.],
      )

      #grid(
        columns: (50%, 50%),
        align(horizon)[Завідувач кафедри \ В. М. Терещенко],
        signature,
      )
    ]
  )
]

#align(center + bottom)[Київ -- 2023]
#pagebreak()

#let leading = 1.5em
#let tab = h(1.27cm) 
#set par(leading: leading, first-line-indent: 1.27cm)
#show par: set block(spacing: leading)
#show outline: set par(first-line-indent: 0mm)
#show terms: set par(first-line-indent: 0mm)

#heading(outlined: false)[Реферат]

Обсяг роботи:
#locate(loc => counter(page).final(loc).at(0)) сторінок,
#locate(loc => counter(figure.where(kind: image)).final(loc).at(0)) ілюстрацій,
#locate(loc => counter(figure.where(kind: table)).final(loc).at(0)) таблиць,
#locate(loc => counter(ref).final(loc).at(0)) використаних джерел.

Ключові слова: ДОКАЗИ З НУЛЬОВИМ РОЗГОЛОШЕННЯМ, АНОНІМНІ ПЕРЕКАЗИ,
БЛОКЧЕЙН, КРИПТОГРАФІЯ, СМАРТ КОНТРАКТИ, ДЕРЕВО МЕРКЛА.

Об'єктом роботи є протокол анонімних переказів криптовалюти на базі
блокчейну Ethereum.

Метою кваліфікаційної роботи є створення й публікація протоколу
для анонімних переказів з відкритим вихідним кодом для покращення
фінансової приватності в публічних блокчейнах.

Інструментами створення є безкоштовний, вільно поширюваний редактор коду
`Neovim` та мова розмітки тексту `Typst`, мови програмування `Noir`,
`TypeScript`, `Solidity`. Використано фреймворк `Hardhat`,
бібліотеку `ethers.js` та сервіс `Etherscan`.

Результат роботи: розроблено та опубліковано реалізацію протоколу
анонімних переказів під ліцензією MIT.

#pagebreak()

#outline(indent: true)

#pagebreak()

= Скорочення та умовні позначення

// API: -- Application Programming Interface
/ DAO: -- Decentralized Autonomous Organization, децентрелізована 
  автономна організація;
/ DeFi: -- Decentralized Finance, децентралізовані фінанси;
/ DLP: -- Discrete Logarithm Problem, задача дискретного логарифму;
/ ERC20: -- широко використовуваний стандарт токенів в блокчейні Ethereum;
/ EVM: -- Ethereum Virtual Machine, середовище виконання смарт-контрактів
  в блокчейні Ethereum;
/ L2: -- Layer 2, рішення другого рівня;
/ MiMC: -- Minimal Multiplicative Complexity, сімейство хешів з мінімальною
  мультиплікативною складністю;
/ MPC: -- Multiparty Computation, протокол багатосторонніх обчислень;
/ PLONK: -- Permutations over Lagrange-bases for Oecumenical Non-interactive 
  arguments of Knowledge;
/ SMT: -- Sparse Merkle Tree, неявне дерево Меркла;
/ SNARK: -- Succinct Non-Interactive ARgument of Knowledge;
/ STARK: -- Scalable Transparent ARgument of Knowledge;
/ UTXO: -- Unspent Transaction Output, невитрачений залишок транзакції --
  відокремлена сума криптовалюти з конктретним власником;
/ ZKP: -- Zero-Knowledge Proof, доказ з нульовим розголошенням;
/ ZKC: -- Zero-Knowledge Circuits, схеми з нульовим розголошенням;

#pagebreak()

= Вступ

У сучасному цифровому світі анонімність та конфіденційність стають
все більш важливими, особливо в контексті фінансових операцій на публічних блокчейнах.
Рівень приватності постійно знаходиться під загрозою через 
розширення можливостей збору даних та нав'язування технологій слідкування.
Станом на 2023 рік існують різні криптовалютні платформи та протоколи,
які надають анонімність та конфіденційність при проведенні транзакцій, кожен
зі своїми ризиками, гарантіями безпеки, унікальними функціями та недоліками.
Однією з ключових технологій, що забезпечує таку анонімність, є докази з
нульовим розголошенням.

Актуальність роботи полягає у постійно зростаючій потребі захисту персональних даних та анонімності у цифровому просторі. Протоколи анонімних переказів, засновані на доказах з нульовим розголошенням, дозволяють реалізувати безпеку і конфіденційність обміну коштами. Це має особливу важливість для таких областей, як фінанси та криптовалюти, де конфіденційність транзакцій є критичною. 
Незважаючи на те, що багато аспектів цих протоколів вже досліджено, ще залишається багато недосконалостей та можливостей оптимізації, вивчення яких є актуальним.

Основна мета роботи полягає в аналізі наявних протоколів анонімних переказів, /*створенні нового або*/ вдосконаленні та реалізації модифікації існуючого протоколу на основі доказів з
нульовим розголошенням для покращення його гнучкості та сумісності з екосистемою блокчейну, 
оцінці ефективності нової реалізації.

Об'єктом дослідження є протоколи анонімних переказів та докази з нульовим розголошенням.
У процесі дослідження використані теоретичні та практичні методи, включаючи
аналіз наукової літератури, математичні моделі, симуляції та реалізацію прототипів.

Можливі сфери застосування результатів роботи включають криптовалютні платформи,
банківські установи, фінтех-компанії та інші організації, які займаються
електронними платежами та фінансовими операціями.

Дана робота базується на реалізації Tornado Cash –- відомого
протоколу для анонімних транзакцій на блокчейні Ethereum. Основні принципи
та ідеї його архітектури адаптовані та розширені для даної роботи, зокрема для
використання мови програмування `Noir` та інтеграції протоколу Aave.

#pagebreak()

#set heading(numbering: (..nums) => {
  if nums.pos().len() == 1 {
    "Розділ " + str(nums.pos().at(0)) + "."
  } else {
    numbering("1.", ..nums)
  }
})

= Огляд доказів з нульовим розголошенням
== Означення та властивості
\

Доказ нульового розголошення можна розглядати як взаємодiю мiж
двома комп’ютерними програмами. Oдну з них називають Прувер, а другу
Верифiкатор. Прувер переконує Верифiкатора, що певне математичне
твердження є iстинним. Будь-який доказ нульового розголошення має
задовольняти три властивостi:

+ *Повнота* (Completeness): якщо Прувер чесний (твердження істинне), то врештi-решт вiн переконає Верифiкатора.
+ *Обґрунтованiсть* (Soundness): Прувер може переконати Верифiкатора лише в тому випадку, якщо твердження iстинне.
+ *Нульовий рiвень знань* (Zero knowledge): Верифікатор не дiзнається жодної iнформацiї, окрім факту істинності твердження.

\
== Приклад: схема Шнорра
\

Схема Шнорра @schnorr є одним із найпростіших та найбільш широко використовуваних
протоколів ZKP. Вона дозволяє стороні довести, що вона знає секретнне число,
не розкриваючи його або будь-яку інформацію стосовно нього. Схема використовується,
зокрема, в HTTPS та SSH.

\

Протокол наступний:

+ *Підготовка*: Перед початком протоколу сторона, яка доводить знання ключа (прувер), та сторона, якій доводиться (верифікатор), домовляються про певне велике просте число $p$ і примітивний корінь $g$ по модулю $p$. Прувер має секрет $x$, який він не хоче розкривати. Верифікатор знає $y = g^x mod p$.
+ *Комітмент*: Прувер обирає випадкове число $r$ і відправляє $t = g^r mod p$  верифікатору.
+ *Виклик*: Верифікатор відправляє пруверу випадкове число $c$.
+ *Відповідь*: Прувер обчислює $s = r + c x mod p-1$ і відправляє s верифікатору.
+ *Перевірка*: Верифікатор перевіряє, що $g^s mod p$ дорівнює $t y^c mod p$. Якщо рівність виконується, то верифікатор приймає доказ. В іншому випадку доказ відхиляється.

#tab У цьому протоколі прувер ніколи не розкриває свій секрет $x$, але все одно може довести,
що він його знає. Одночасно верифікатор може бути впевнений, що прувер знає секрет, не отримуючи
жодної додаткової інформації.

Цей протокол використовує криптографічне припущення про нерозв'язність DLP.

\
== Перетворення Фіата-Шаміра
\

Перетворення Фіата-Шаміра @fiat-shamir -- це важлива техніка в криптографії, яка дозволяє
перетворити інтерактивний протокол ZKP на неінтерактивний. Це важливо, тому що
інтерактивність може бути проблематичною для багатьох реальних застосувань, особливо в
онлайн-системах, де велика кількість взаємодій може бути обтяжливою.

У стандартному інтерактивному ZKP, прувер та верифікатор обмінюються декількома
повідомленнями. У випадку протоколу Шнорра, наприклад, прувер починає з надсилання
комітменту, потім верифікатор відправляє випадкове число як виклик, і прувер відповідає
на цей виклик.

Перетворення Фіата-Шаміра дозволяє усунути необхідність в інтерактивності шляхом заміни
виклику верифікатора на криптографічно безпечний хеш від комітменту прувера. Таким
чином, прувер може створити доказ без взаємодії з верифікатором: він створює свій
комітмент, обчислює хеш від цього комітменту, використовує цей хеш як виклик і
відповідає на цей виклик. Згодом верифікатор може перевірити доказ, перевіривши,
що хеш від комітменту прувера справді відповідає виклику і що відповідь правильно
відповідає на виклик.

Це перетворення робить можливим застосування ZKP в неінтерактивних контекстах, таких як
криптовалюти та блокчейн. Проте воно залежить від існування криптографічно безпечних
хеш-функцій, які вважаються стійкими до злому.

\ \ \
== zk-SNARK та довірене налаштування
\

Сімейство пруф-систем zk-SNARK є одним з найпопулярніших на сьогодняшній день,
оскільки дозволяє генерувати короткі докази, які можна швидко верифікувати - незалежно від
розміру обчислень, що доводяться. Проте, вони мають великий спільний недолік.

Довірене налаштування (_trusted setup_) в zk-SNARK є важливою частиною процесу, оскільки
воно генерує початкові параметри, які використовуватимуться під час створення та перевірки
доказів. Налаштування має бути виконано безпечним і надійним способом, оскільки від цього
залежить безпека системи.

Одним із поширених способів проведення довіреного налаштування є протокол багатосторонніх
обчислень (MPC):

+ Кожен учасник самостійно генерує частину параметрів налаштування та зберігає свою частину в таємниці.
+ Кожен учасник використовує свою секретну частину, щоб створити публічну частину параметрів налаштування.
+ Публічні частини від усіх учасників об’єднуються для створення остаточних параметрів для системи zk-SNARK.
+ Приватні частини учасників знищуються.

#tab Властивість безпеки цієї установки полягає в тому, що доки принаймні один учасник успішно
знищить свою секретну частину, остаточні параметри не можуть бути використані для
створення хибних доказів.

Одним із прикладів такого підходу на практиці була "церемонія" ZСash, яка являла собою
протокол багатосторонніх обчислень за участю шести учасників. Протокол був розроблений
таким чином, що навіть якби п’ятеро учасників змовилися, щоб зберегти свої секрети та
створити фальшиві докази, зусилля були б марними, доки принаймні один учасник правильно
знищив свій секрет. Церемонія була проведена з високим рівнем свідомості безпеки,
включаючи заходи для запобігання side-channel attacks, які могли стати причиною витоку
секретів.

Хоча цей процес суттєво зменшує ризик, пов’язаний із довіреним налаштуванням, він не
усуває його повністю. Таким чином, системи, які не вимагають надійних установок, як-от
zk-STARK і Bulletproofs, можуть бути більш привабливими в певних контекстах.

\
== Порівняння SNARK, STARK та Bulletproof
\

Тут описані приклади сучасних пруф-систем з їх перевагами та недоліками (@proof-systems).

*zk-SNARK*. Частина *S* (_succinct_, стислий) означає, що докази невеликі та їх швидко 
верифікувати, що є ключовою перевагою. Однак вони вимагають окремий _trusted setup_ для
кожної схеми ZKC, що є суттєвим недоліком. Підвид SNARKів під назвою PLONK потребує 
один _trusted setup_ для всіх схем не більше певного розміру (_universal trusted setup_),
що однозначно є покращенням, хоч і не повним вирішенням проблеми.
 
*zk-STARK*. Вони схожі на zk-SNARK, але не вимагають довіреного налаштування, що допомагає
уникнути вищезгаданого ризику безпеки. Вони також стійкі до квантових алгоритмів, адже 
їх безпека залежить тільки від обраної хеш-функції. Однак докази, згенеровані zk-STARK,
більші, ніж ті, що згенеровані zk-SNARK, що може бути недоліком.

*Bulletproof*. Це ще один тип ZKP, який не вимагає довіреного налаштування. Вони в
основному використовуються для покращення конфіденційності в мережі Bitcoin. Розмір
Bulletproof'a логарифмічно зростає як із розміром твердження, яке потрібно підтвердити,
так і з параметром безпеки, що робить їх більш здатними до масштабування. 
Однак вони не такі стислі, як zk-SNARK або zk-STARK, тобто потребують більше
обчислювальних ресурсів для верифікації.

#[
  #set par(leading: 0.5em)
  #figure(
    caption: "Порівняльна характеристика пруф-систем",
    table(
      columns: (auto, auto, auto, auto),
      align: center + horizon,
      inset: 10pt,
      [], [*SNARK*], [*STARK*], [*Bulletproof*],
      [Алгоритмічна складність: Прувер], [$O(n log(n))$], [$O(n "poly-log"(n))$], [$O(n log(n))$],
      [Алгоритмічна складність: Верифікатор], [$O(1)$], [$O("poly-log"(n))$], [$O(n)$],
      [Розмір доказу], [$O(1)$], [$O("poly-log"(n))$], [$O(log(n))$],
      [Потрібен trusted setup], [так], [ні], [ні],
      [Стійкість до квантових алгоритмів], [ні], [так], [ні],
      [Криптографічні припущення], [DLP + secure bilinear pairing], [хеші, стійкі до колізій], [DLP],
    )
  ) <proof-systems>
]

#pagebreak()

= Огляд існуючих протоколів анонімних переказів
== ZCash
\

ZCash (ZEC) це відкрита децентралізована криптовалюта, яка була запущена в 2016 році. Вона була створена з метою надання більш приватної альтернативи іншим криптовалютам, зокрема Bitcoin. В основу ZCash покладено технологію zk-SNARKs, описану в попередньому розділі.

ZCash дозволяє користувачам вибирати, чи робити свої транзакції приватними (_shielded
transactions_), адже вони дорожчі за публічні транзакції та вимагають від користувача
генерації доказу ZKP.

У ZCash, технологія zk-SNARK дозволяє створити транзакцію з доказом, що відправник має достатньо
коштів для проведення транзакції, але без розкриття суми транзакції, відправника та отримувача.
Це гарантує приватність транзакції.

Отже, як це працює на практиці? Нижче наведено кроки, які відбуваються при використанні
конфіденційного переказу в ZCash:

+ *Створення комітменту*: Відправник генерує секретний ключ та публічний ключ. Відправник тоді бере вхідні UTXO, суму, яку вони хочуть відправити, та адресу отримувача, та створює "комітмент". Комітмент є просто хешем всіх цих деталей, який потім записується в блокчейн.
+ *Створення доказу*: Відправник тоді генерує ZKP, що вони знають секретний ключ, який відповідає публічному ключу в комітменті, і що вхідні UTXO містять достатньо коштів для виконання транзакції.
+ *Верифікація*: Коли відправник передає доказ в мережу, вузли в мережі можуть перевірити доказ без відкриття комітменту. Якщо доказ є вірним, транзакція додається в блокчейн, але самі деталі транзакції залишаються прихованими. Завдяки технології zk-SNARKs, ZCash забезпечує приватність транзакцій, не жертвуючи безпекою або цілісністю своєї мережі.

\
== Monero
\

Monero (XMR) - це приватна, децентралізована і безпечна криптовалюта, яка була впроваджена в
квітні 2014 року. Вона стала популярною, завдяки наголосу на анонімності та приватності. Це
забезпечено через застосування декількох криптографічних технологій:

+ *Кільцеві Підписи* (_Ring Signatures_): використовуються для забезпечення анонімності відправника. Вони дозволяють відправнику підписати транзакцію згрупою можливих підписувачів, тим самим забезпечуючи анонімність, оскільки неможливо визначити, хто з групи дійсно підписав транзакцію.
+ *Сховані адреси* (_Stealth Addresses)_: Monero використовує сховані адреси для забезпечення анонімності отримувача. Коли транзакція виконується, генерується унікальна одноразова адреса, яка асоціюється з кожною транзакцією на стороні отримувача. Це гарантує, що зовнішній спостерігач не може прослідкувати дві транзакції до того ж отримувача.
+ *Кільцеві конфіденційні транзакції* (_RingCT_): використовуються для приховування суми транзакції. Це розширення технології кільцевих підписів, що використовує комітменти Педерсена, які є гомоморфними за додаванням (сума двох комітментів дорівнює комітменту суми). Вони дозволяють довести, що сума входів транзакції дорівнює сумі виходів, без необхідності відкривати фактичні суми.
+ *Криптовалютна мережа Kovri*: Monero планує впровадження мережі Kovri, що дозволить забезпечити анонімність на рівні IP-адреси, використовуючи технологію оніон-маршрутизації. Ця технологія вже давно використовуються, наприклад, в браузері Tor.

\
== MimbleWimble
\

Mimblewimble - це криптовалютний протокол, представлений у 2016 році. Він відрізняється тим, що
надає високий рівень приватності і значно більшу ефективність за масштабування в порівнянні з
багатьма традиційними криптовалютами.

MimbleWimble використовує декілька криптографічних технологій для забезпечення анонімності 
переказів.

*1. Приховування транзакцій*

У MimbleWimble приховування транзакцій здійснюється за допомогою комітментів Педерсена
(Pedersen Commitments), так само як і в Monero. Kомітмент Педерсена - це гомоморфний за
додаванням криптографічний примітив, який дозволяє зберігати значення таким чином, що воно
приховане, але все ще може бути використане в математичних обчисленнях. Тобто ви можете додавати
зашифровані числа, і отримати той самий (зашифрований) результат, якщо б ви виконували ці
обчислення на незашифрованих числах.

Коли користувач виконує транзакцію, він створює комітмент для кожного залишку (UTXO)
транзакції. Ці комітменти потім використовуються для перевірки того, що загальна сума входів
транзакції дорівнює загальній сумі залишків. Це гарантує, що транзакція є дійсною, без
необхідності відкривати реальні суми переказів.

*2. Об'єднання транзакцій*

MimbleWimble також використовує технологію, відому як CoinJoin, для об'єднання транзакцій.
CoinJoin - це процес, в якому кілька користувачів об'єднують свої транзакції в одну, щоб змішати
інформацію про відправників і отримувачів.

Коли транзакції об'єднуються за допомогою CoinJoin, всі входи та виходи об'єднаних транзакцій
перемішуються разом. Це означає, що неможливо визначити, який вхід відповідає якому виходу, що
допомагає забезпечити анонімність.

Важливо зазначити, що об'єднання транзакцій в MimbleWimble відбувається на рівні протоколу, що
означає, що всі транзакції автоматично об'єднуються, на відміну від деяких інших технологій
CoinJoin, які вимагають активної участі користувачів.

Основою цих механізмів є криптографія на еліптичних кривих, на яких будуються ключові
криптографічні примітиви, що використовується в MimbleWimble.

\
== Aztec
\

Протокол Aztec -- це рішення другого рівня (_L2_), орієнтоване на конфіденційність, розгорнуте в
мережі Ethereum. Для досягнення своїх цілей, протокол використовує ZKP, зокрема zk-SNARKи, схоже на
те, як це робить протокол ZCash. На жаль, з 21.03.2021 протокол більше не приймає депозити -- 
розробники вирішили його згорнути.

Основною метою Aztec є забезпечення рівня конфіденційності та приватності на Ethereum, який зазвичай
недоступний у транзакціях за замовчуванням. Крім того, Aztec створено для надання переваг
масштабованості. Використання zk-SNARK допомагає стиснути дані транзакцій, що робить їх потенційно
ефективнішими (а отже і дешевшими), ніж традиційні транзакції Ethereum. 

На відміну від ZCash, що є достатньо примітивним протоколом, Aztec підтримує унікальні 
функції, такі як:

+ *Приватні активи*. Aztec підтримує не тільки приватні перекази ефіру, а й ERC20 токенів. Це дозволяє використовувати конфіденційні аналоги будь-яких цифрових активів, що реалізують даний стандарт.
+ *Модель аккаунтів* замість UTXO. Це дозволяє бути більш сумісними з протоколом Ethereum ефективніше обробляти депозити та виводи активів з протоколу.
+ Інтеграція з DeFi протоколами через *Aztec Connect*.

\
=== Aztec Connect
\

Aztec Connect -- це розширення протоколу Aztec, що дозволяє взаємодіяти з DeFi протоколами 
на Ethereum, використовуючи конфіденційні активи, що знаходяться в Aztec L2. Це було можливим
завдяки підтримці спеціальних інфраструктурних смарт-контрактів "мостів", що інтегрували б Aztec 
з іншими протоколами, такими як Uniswap, Aave та ін.

Алгоритм приблизно такий:

+ Користувач, або кілька користувачів Aztec хочуть використати DeFi протокол "X".
+ Активи цих користувачів збираються та використовуються в одній транзакції на Ethereum, що виконується від імені протоколу Aztec -- тож неможливо зрозуміти, хто саме з усіх користувачів скористався функцією. Що саме виконується у транзакції, залежить від протоколу "X".
+ Генеруються та валідуються ZKP про можливість виконання цієї транзакції користувачами.
+ Усі отримані активи в результаті транзакції (якщо є), розподіляються між користувачами-ініціаторами, як це прописано на контракті-мості.

#pagebreak()

= Реалізація

== Опис протоколу
//== Relayers
\

За основу протоколу була взята архітектура Tornado Cash @tornado. Протокол може бути
розгорнутий на будь-якому EVM-сумісному блокчейні та складається з таких смарт-контрактів:

- `Tornado`, що буде мати інтерфейс для депозитів та виводів, а також буде підтримувати дерево Меркла з комітментів користувачів.
- `Hasher`, що буде містити реалізацію криптографічної хеш-функції MiMC для використання у дереві Меркла.
- `Verifier`, що буде виступати у ролі верифікатора ZKP для виводів коштів.

#tab Усі депозити та виводи мають мати однакову валюту та деномінацію, адже інакше можна буде
при виведенні відслідкувати користувача, що робив депозит - компрометуючи анонімність переказу.

Алгоритм взаємодії наступний:

+ Користувач генерує два набори байтів $s$ та $r$. $s$ називається секретом, $n$ називається обнулювачем (_nullifier_). Обраховується комітмент $C = H(s || n)$, де $H$ - хеш-функція MiMC.
+ Користувач робить депозит у смарт-контракт `Tornado`, надаючи контракту комітмент $C$.
+ Смарт-контракт зберігає $C$ у дереві Меркла та оновлює його кореневий хеш.
+ Користувач відправляє надійним каналом значення $s$ та $n$ отримувачу коштів (офф-чейн, тобто поза блокчейном).
+ Отримувач обчислуює $N = H(n)$ та генерує такий ZKP $P$, що доводить, що отримувач знає такі $s$ та $n$, що $C = H(s || n)$, що дійсно $N = H(n)$, та що $C$ належить дереву Меркла з кореневим хешем $R$ (за допомогою шляху Меркла).
+ Отримувач відправляє $N$, $R$ та $P$ на смарт-контракт `Tornado` із запитом на вивід коштів.
+ Смарт-контракт перевіряє, що обнулювач $N$ ще не був використаний, кореневий хеш $R$ співпадає зі значенням на контракті, та делегує верифікацію доказу $P$ контракту `Verifier`. Якщо всі умови виконані, контракт відправляє кошти отримувачу.

#tab У контракті `Hasher` xеш MiMC використовується через його низьку мультиплікативну складність та відносну 
простоту реалізації в ZKC. 
Цей компроміс потрібен тому, що він буде обчислюватись на смарт-контракті $2 N$ разів під час кожного депозиту
для оновлення дерева Меркла (де $N$ - висота дерева), що може стати причиною великих комісій на транзакцію 
у EVM-сумісних блокчейнах. Також, ZKC працюють набагато ефективніше з мультиплікативними хешами аніж з перестановочними.
Використання, наприклад, хешу `keccak256` може спричинити надмірно великі витрати на генерацію доказу, 
хоч цей хеш і є одним з найдешевших у EVM, але він є перестановочним.

У контракті `Verifier` використовується пруф-система PLONK, що має кілька переваг над стандартними zk-SNARK
(такими як Groth16, що використовується в оригінальній реалізації Tornado Cash):

- Через універсальне довірене налаштування, що підтримується в PLONK, можна використовувати один і той самий верифікатор для усіх екзмеплярів протоколу (різні валюти, різні деномінації і т.і.).
- ZKC можна писати на сучасній мові `Noir`, що є більш високорівневою та гнучкою ніж `Circom` з оригінальної реалізації.
- Докази досить легко генерувати прямо у браузері, через зручну прив'язку бібліотеки `barretenberg` до WebAssembly.

\
== Множина анонімності
\

Множина анонімності (_anonymity set_) -- це група транзакцій, які неможливо відрізнити 
одна від одної. Коли користувачі вносять або знімають кошти за допомогою Tornado, 
їхні транзакції змішуються з транзакціями інших користувачів, щоб підвищити конфіденційність 
і заплутати слід транзакцій.

Множина анонімності представляє собою загальну множину транзакцій, які потенційно можуть бути змішані 
з конкретною транзакцією. Чим більша множина анонімності, тим більший рівень приватності надається 
користувачам. Якщо множина анонімності велика, стає складніше відстежувати потік коштів і 
пов’язувати конкретні депозити з конкретними виводами.

Для протоколу Tornado розмір множини анонімності для транзакції виводу в будь-який момент часу дорівнює 
кількості користувачів, що здійснили депозит до цього часу, адже будь-хто з них може
здійснювати вивід.

\
== Доведення безпеки протоколу
\

\
== Дерево Меркла
\

Дерево Меркла, що також відоме як хеш-дерево, це структура даних, що представляє
собою ідеальне двійкове дерево (тобто таке повне двійкове дерево, в якому листи 
лежать на однаковій відстані від кореня). Воно назване на честь Ральфа Меркла, що винайшов
його в 1979 році.

Дерево Меркла складається з двох основних типів елементів:

- *Внутрішні вузли*: Це елементи дерева, які мають рівно два нащадки і містять хеш від конкатенації значень нащадків $H_("AB") = H(H_A || H_B)$.
- *Листи*: Це кінцеві вузли дерева, які містять фактичні дані або хеш від фактичних даних (в залежності від реалізації).

#tab Основна відмінність від хеш-таблиці полягає в тому, що одна гілка хеш-дерева може бути
завантажена у необхідний час, а цілісність кожної гілки може бути перевірена негайно, навіть
якщо все дерево ще недоступне.

Основною перевагою дерева Меркла висоти $N$ є можливість довести за $O(N)$ належність дереву певного
елемента, маючи лише кореневий хеш (_root hash_) та хеші сусідніх вузлів на шляху до
відповідного листа. Цей алгоритм називають доказом Меркла, а масив сусідніх хешів - шляхом
Меркла (@merkle-proof).

\
#figure(
  caption: "Схема доказу Меркла",
  image("./img/merkle_proof.png")
) <merkle-proof>
\

Дерево Меркла важливе в контексті блокчейну, оскільки воно дозволяє ефективно зберігати великі
обсяги даних у якості рут-хешу (тобто хешу кореневого вузла) дерева Меркла,
побудованого на цих даних. Це дозволяє здійснювати перевірку на належність (_membership proof_),
надаючи шляхи Меркла.

Далі опишемо конкретні варіанти реалізації дерева Меркла, їх переваги та недоліки.

\
=== Неявне дерево Меркла
\

Неявне (або розріджене) дерево Меркла (_Sparse Merkle Tree_, SMT) -- це варіант реалізації дерева
Меркла, який дозволяє зберігати лише $O(N dot K)$ вузлів де $K$ - це кількість непустих листів. На
відміну від наївної реалізації, де збрігається кожен з $2^N - 1$ вузлів.

Стандартне дерево Меркла має зберігати усі свої вузли явно. З іншого боку, неявне дерево Меркла
розроблено таким чином, щоб бути ефективним, якщо дерево представляє велику кількість даних,
більшість із яких є порожніми або мають значення за замовчуванням.

Це особливо корисно для застосунків в блокчейні, де дерево може відображати стан цілої книги з
адресами для мільйонів або мільярдів облікових записів, більшість із яких може взагалі не мати
жодних збережених значень.

SMT побудовано таким чином, що воно має достатньо листкових вузлів для представлення всіх можливих
ключів даних (адрес, слотів тощо), але лише вузли на шляху від кореня до листа, зі значеннями,
відмінними від дефолтних, потрібно зберігати або створювати, що економить багато місця. 

Для дефолтних значень можна заздалегідь порахувати хеш на $i$-тому рівні дерева за рекуррентною
формулою $H^"default"_i = H(H^"default"_(i-1) || H^"default"_(i-1))$, і використовувати їх там, де
у вузла немає явно збереженого значення. Таких хешів буде рівно $N$.

\
=== Інкрементальне дерево Меркла
\

Інкрементальне дерево Меркла - це варіант реалізації дерева Меркла, що використовується
для застосунків, де важливо тільки підтримувати актуальний рут-хеш дерева, а також підтримувати
операцію поступового додавання елементів.

Через те, що немає вимоги зберігати усі вузли, а також через те, що елементи додаються поступово
(тобто, спочатку - у перший лист, наступний - у другий лист, і т.д.), ми можемо сильно зменшити 
необхідну пам'ять для підтримки такого дерева - від $O(N dot K)$ до $O(N)$.

Адже перманентна пам'ять (_storage_) на EVM-сумісних блокчейнах дорога, це сильно зменшує ціну підтримки
такого дерева на смарт-контракті.

Алгоритм додавання елементу наступний:

- Будемо підтримувати масив $H^"filled"$, де будемо зберігати останні оновлені вузли на кожному рівні дерева, але тільки якщо вони є лівими піддеревами батьківського вузла.
- На кожному рівні дерева, починаючи з листів, будемо обчислювати новий хеш батьківського вузла:
  - якщо новий вузол -- лівий, то хеш дорівнює $H^"new"_(i+1) = H(H^"new"_i || H^"default"_i)$
  - якщо новий вузол -- правий, то хеш дорівнює $H^"new"_(i+1) = H(H^"filled"_i || H^"new"_i)$
  - якщо новий вузол -- лівий, також оновлюємо $H^"filled"_i := H^"new"_i$

\
== Протокол Aave 
\

Aave - це децентралізований протокол позик, розгорнутий на блокчейні Ethereum. Aave є скороченням від слова "привид" на фінській мові, що символізує прозорість в криптоекосистемі. 

Aave має відкритий вихідний код та є некастодіальним, тобто не має активів під керуванням фізичних чи юридичних осіб. Протокол дозволяє користувачам здійснювати операції позики, кредитування та вкладення криптовалюти над близько 20 видами ERC20-токенів без необхідності підтвердження особистості або взаємодії з фінансовими інститутами.

Особливості Aave:

+ *Вклади та позики.* Користувачі можуть внести свої криптовалютні активи в пули ліквідності Aave, заробляючи відсотки доходу. Вони також можуть позичати активи, платячи відсотки за позику. Це дає можливість надавати надійне P2P кредитування без посередників. Відсотки комісії, що користувачі платять за позики, розподіляються поміж користувачами-вкладчиками.
+ *Flash Loans* (Миттєві позики). Це одна з унікальних особливостей Aave. Flash Loans дозволяють користувачам позичати будь-яку кількість активів без забезпечення, за умови, що позика відшкодовується в одному і тому ж блоку Ethereum. Це відкриває широкий спектр можливостей для арбітражу, перебудови портфоліо та ін.
+ *aTokens.* Коли користувачі вносять активи в Aave, вони отримують відповідні aTokens. aTokens автоматично накопичують відсотки в реальному часі, що дозволяє користувачам бачити свої доходи на постійній основі.
+ *Стабільні та нестабільні ставки.* Aave дозволяє користувачам вибрати між стабільними та нестабільними ставками при позиці активів.

#tab Aave пропонує багато можливостей як для користувачів, так і розробників екосистеми Ethereum, адже
Aave досить легко інтегрувати у інші протоколи - як, наприклад, зробили Yearn та Aztec.

\
=== Ризики Aave
\

Як і всі інші DeFi протоколи, Aave має кілька потенційних ризиків, які користувачам варто враховувати. Ось декілька з них:

+ *Ризик смарт-контрактів.* Якщо в коді смарт-контракту Aave або в будь-якому з його контрактів-залежностей є помилки, це може призвести до втрати коштів. Це може бути результатом помилок у коді або зловмисного взлому. Aave проводила аудити свого коду, але це не гарантує повної відсутності помилок.
+ *Ризик ліквідації.* Це ризик, що активи, які ви залишили в якості застави, можуть значно впасти в ціні. Якщо це станеться, ваша позика може стати небезпечно великою в порівнянні з заставою, і ваші заставні активи можуть бути ліквідовані, щоб покрити позику. Варто зазначити, що цей ризик присутній тільки для користувачів, що позичали активи, а не для вкладчиків.
+ *Регуляторний ризик.* Уряди по всьому світу продовжують розвивати своє регулювання криптовалют, і будь-які майбутні зміни в законодавстві можуть вплинути на роботу Aave або на можливість користувачів використовувати Aave.
+ *Ризик оракулів.* Для відслідковування відношень цін токенів в заставі та у позиці, Aave використовує т. зв. оракули -- смарт-контракти, що отримують дані із зовнішнього світу. Від цін, що вони надають, залежить, чи будуть здійснюватись ліквідації. Отже, якщо якимось чином дані оракулів будуть недоступні чи невірні, можуть бути хибно здійснені (або не здійснені) ліквідації позицій користувачів.

\
=== Flash Loans
\

Миттєва позика (_flash loan_) є інноваційною функцією, що була вперше запроваджена протоколом
Aave в DeFi просторі. Це тип позики, що дозволяє користувачам позичити будь-яку доступну
кількість активів без застави, проте позика повинна бути повернута в рамках однієї транзакції
Ethereum.

Це працює наступним чином:

+ Користувач бере Flash Loan.
+ Користувач використовує ці кошти для виконання певних операцій, як-то арбітраж, переконфігурація портфоліо, само-погашення позики тощо.
+ Користувач повертає позику з невеликою платою за користування в межах тієї ж транзакції.

#tab Якщо позика не повертається, або повертається не повністю, транзакція відкидається і
стан блокчейна повертається до стану перед транзакцією (_revert_), адже будь-яка 
транзакція в Ethereum є атомарною (тобто, вона або виконується повністю, або не 
виконується взагалі).

Цей механізм дозволяє користувачам використовувати значні капіталовкладення для короткострокових
операцій без необхідності великих інвестицій, а також знижує ризики пов'язані з ціною активів.

\
=== Інтеграція
\

Факт того, що кошти користувачів можуть досить довго знаходитись на контракті протоколу,
це спонукає до думки про використання цих коштів для генерації додаткових доходів. Ці доходи
потім можуть бути використані кількома способами, такими як:

- Оплата послуг релейерів
- Фандинг підтримки та покращення протоколу розробниками
- Створення фонду протоколу та керування ним через DAO
- Розподілення доходів поміж користувачами протоколу
- Донати на ЗСУ

#tab Варто зазначити, що розподілення доходів неможливо здійснювати пропорційно до часу, що вкладчики
тримали кошти на протоколі, адже підчас виводу коштів неможливо зрозуміти, коли (і ким)
було здійснене початкове вкладення.

Генерувати доходи для протоколу можемо двома способами:

*1. Вкладення в Aave*

Кожен депозит ETH у протокол будемо автоматично вкладати в Aave, тобто конвертувати в aWETH.
Таким чином, ми збільшуємо ризик через взаємодію зі складною системою смарт-контрактів та оракулів,
проте отримуємо близько 2% річних доходів за наші вкладення.

При виводі з протоколу, ми аналогічним чином закриватимемо нашу позицію на Aave, таким чином
конвертуючи aWETH у ETH, який ми і повертатимемо користувачу. Залишок конвертації (тобто
отримані на вкладенні відсотки) залишимо на контракті для майбутнього використання.

*2. Flash Loans*

Так як дуже імовірно, що на протоколі у будь-який момент часу буде значна кількість коштів,
має сенс реалізувати там функцію `flashLoan`, подібну до тої, що є у Aave. Вона даватиме змогу
користувачам миттєво позичити весь баланс контракту протоколу без застави, 
за умови що позика буде погашена у межах тієї самої транзакції. За кожну таку позику
братитемо комісію 0.3%, що і буде джелелом доходу.

\
== Розрахунок потенційних прибутків
\

Проаналізувавши події (_events_) `Deposit` та `Withdrawal` на смарт-контрактах Tornado Cash, а також
події `FlashLoan` на смарт-контракті Aave за допомогою Etherscan API, можемо розрахувати
потенційний прибуток для протоколу від наведених вище інтеграцій. 

Нижче наведені графіки потенційних прибутків протоколу:
// TODO


#pagebreak()

#set heading(numbering: none)

= Висновки

// TODO

#pagebreak()

= Перелік джерел посилання
#bibliography(title: none, "sources.yml")

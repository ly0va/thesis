#let fontsize = 14pt
#show heading: set text(size: fontsize)
#show heading.where(level: 1): it => [#it \ ]
#show heading.where(level: 1): set align(center)
#set text(size: fontsize, font: "Noto Serif")
#show raw: set text(size: fontsize)
#show math.equation: set text(size: 16pt)
#set page(
  paper: "a4",
  margin: (
    top: 20mm,
    bottom: 20mm,
    left: 25mm,
    right: 10mm
  ),
  header: [
    #align(right)[
      #counter(page).display(i => if i != 1 [#i])
    ]
  ]
)

#align(center)[
  *КИЇВСЬКИЙ НАЦІОНАЛЬНИЙ УНІВЕРСИТЕТ \
  ІМЕНІ ТАРАСА ШЕВЧЕНКА* \
  Факультет комп’ютерних наук та кібернетики \
  Кафедра математичної інформатики \ \ \
  *Кваліфікаційна робота \
  на здобуття ступеня бакалавра* \
  за освітньо-професійною програмою “Інформатика” \
  спеціальності 122 Комп'ютерні науки на тему: \ \
  *РЕАЛІЗАЦІЯ ПРОТОКОЛУ АНОНІМНИХ ПЕРЕКАЗІВ
  ЗА ДОПОМОГОЮ ДОКАЗІВ З НУЛЬОВИМ РОЗГОЛОШЕННЯМ* \ \ \
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
    \
    Науковий керівник: \
    Член-кореспондент НАН України, професор \
    Анісімов Анатолій Васильович
  ],
  [\ \ #signature],
)

\ \
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
  ]
)

#align(center + bottom)[Київ -- 2023]
#pagebreak()

#let leading = 1.5em
#set par(leading: leading, first-line-indent: 1.27cm)
#show par: set block(spacing: leading)
#show outline: set par(first-line-indent: 0mm)
#show terms: set par(first-line-indent: 0mm)

#heading(outlined: false)[РЕФЕРАТ]

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

Інструментом створення є безкоштовний, вільно поширюваний редактор коду
`Neovim` та мова розмітки тексту `Typst`, мови програмування `Noir`,
`TypeScript`, `Solidity`. Використано фреймворк `Hardhat` та
бібліотеку `ethers.js`.

Результат роботи: розроблено та опубліковано реалізацію протоколу
анонімних переказів під ліцензією MIT.

#pagebreak()

#outline(title: [ЗМІСТ])
#pagebreak()

= ВСТУП

У сучасному цифровому світі анонімність та конфіденційність стають
все більш важливими, особливо в контексті фінансових операцій.
Станом на 2023 рік існують різні криптовалютні платформи та протоколи,
які надають анонімність та захист конфіденційності при проведенні транзакцій.
Однією з ключових технологій, що забезпечує таку анонімність, є докази з
нульовим розголошенням.

Актуальність даної роботи полягає в розробці протоколу анонімних переказів,
заснованого на доказах з нульовим розголошенням, що забезпечить високий рівень
конфіденційності та безпеки для користувачів. Робота виконана на новій
мові програмування схем з нульовим розголошенням `Noir`, що сприятиме розвитку
мови та доповнить її екосистему проектів, а також допоможе покращити її
надійність шляхом безпосереднього тестування.

Основна мета роботи полягає в аналізі наявних протоколів анонімних переказів
та створенні нового або модифікації існуючого протоколу на основі доказів з
нульовим розголошенням.

Об'єктом дослідження є протоколи анонімних переказів та докази з нульовим розголошенням.
У процесі дослідження будуть використані теоретичні та практичні методи, включаючи
аналіз наукової літератури, математичні моделі, симуляції та реалізацію прототипів.

Можливі сфери застосування результатів роботи включають криптовалютні платформи,
банківські установи, фінтех-компанії та інші організації, які займаються
електронними платежами та фінансовими операціями.

Дана робота базується на реалізації Tornado Cash @tornado – відомого
протоколу для анонімних транзакцій на блокчейні Ethereum. Основні принципи
та ідеї Tornado Cash адаптовані та розширені для даної роботи, зокрема для
використання мови програмування `Noir`.

#pagebreak()

= СКОРОЧЕННЯ ТА УМОВНІ ПОЗНАЧЕННЯ

/ ZKP: Zero-Knowledge Proof, доказ з нульовим розголошенням;
/ ZKC: Zero-Knowledge Circuits, схеми з нульовим розголошенням;
/ SNARK: Succinct Non-Interactive ARgument of Knowledge;
/ STARK: Scalable Transparent ARgument of Knowledge;
/ EVM: Ethereum Virtual Machine, середовище виконання смарт-контрактів
  в блокчейні Ethereum;
/ ERC20: широко використовуваний стандарт токенів в блокчейні Ethereum;
/ DLP: Discrete Logarithm Problem, задача дискретного логарифму;

#pagebreak()

#set heading(numbering: (..nums) => {
  if nums.pos().len() == 1 {
    "РОЗДІЛ " + str(nums.pos().at(0)) + "."
  } else {
    numbering("1.", ..nums)
  }
})

= ОГЛЯД ДОКАЗІВ З НУЛЬОВИМ РОЗГОЛОШЕННЯМ
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

Схема Шнорра @schnorr є одним із найпростіших та найбільш широко використовуваних протоколів ZKP. Вона дозволяє стороні довести, що вона знає секретнне число, не розкриваючи його або будь-яку інформацію стосовно нього. Схема використовується, зокрема, в HTTPS та SSH.

Протокол наступний:

+ *Підготовка*: Перед початком протоколу сторона, яка доводить знання ключа (прувер), та сторона, якій доводиться (верифікатор), домовляються про певне велике просте число $p$ і примітивний корінь $g$ по модулю $p$. Прувер має секрет $x$, який він не хоче розкривати. Верифікатор знає $y = g^x mod p$.
+ *Комітмент*: Прувер обирає випадкове число $r$ і відправляє $t = g^r mod p$  верифікатору.
+ *Виклик*: Верифікатор відправляє пруверу випадкове число $c$.
+ *Відповідь*: Прувер обчислює $s = r + c x mod p-1$ і відправляє s верифікатору.
+ *Перевірка*: Верифікатор перевіряє, що $g^s mod p$ дорівнює $t y^c mod p$. Якщо рівність виконується, то верифікатор приймає доказ. В іншому випадку доказ відхиляється.

У цьому протоколі прувер ніколи не розкриває свій секрет $x$, але все одно може довести, що він його знає. Одночасно верифікатор може бути впевнений, що прувер знає секрет, не отримуючи жодної додаткової інформації.

Цей протокол використовує криптографічне припущення про нерозв'язність DLP.

\
== Перетворення Фіата-Шаміра
\

Перетворення Фіата-Шаміра @fiat-shamir -- це важлива техніка в криптографії, яка дозволяє перетворити інтерактивний протокол ZKP на неінтерактивний. Це важливо, тому що інтерактивність може бути проблематичною для багатьох реальних застосувань, особливо в онлайн-системах, де велика кількість взаємодій може бути обтяжливою.

У стандартному інтерактивному ZKP, прувер та верифікатор обмінюються декількома повідомленнями. У випадку протоколу Шнорра, наприклад, прувер починає з надсилання комітменту, потім верифікатор відправляє випадкове число як виклик, і прувер відповідає на цей виклик.

Перетворення Фіата-Шаміра дозволяє усунути необхідність в інтерактивності шляхом заміни виклику верифікатора на криптографічно безпечний хеш від комітменту прувера. Таким чином, прувер може створити доказ без взаємодії з верифікатором: він створює свій комітмент, обчислює хеш від цього комітменту, використовує цей хеш як виклик і відповідає на цей виклик. Згодом верифікатор може перевірити доказ, перевіривши, що хеш від комітменту прувера справді відповідає виклику і що відповідь правильно відповідає на виклик.

Це перетворення робить можливим застосування ZKP в неінтерактивних контекстах, таких як криптовалюти та блокчейн. Проте воно залежить від існування криптографічно безпечних хеш-функцій, які вважаються стійкими до злому.

\ \
== Порівняння SNARK, STARK та Bulletproof
\

// TODO: overview

#[
  #set par(leading: 0.5em)
  #figure(table(
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
  ))
]

#pagebreak()

= ОГЛЯД ІСНУЮЧИХ ПРОТОКОЛІВ АНОНІМНИХ ПЕРЕКАЗІВ

== Zcash
== Aztec
== Tornado Cash
== Monero
== Mimblewimble

#pagebreak()

= РЕАЛІЗАЦІЯ
#pagebreak()

#set heading(numbering: none)

= ВИСНОВКИ
#pagebreak()

= ПЕРЕЛІК ДЖЕРЕЛ ПОСИЛАННЯ
#bibliography(title: none, "sources.yml")

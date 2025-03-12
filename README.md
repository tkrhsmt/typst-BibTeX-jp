# typst-BibTeX-jp
日本語／英語文献 Typstパッケージ

## 本パッケージの特徴

- 日本語文献と英語文献が混在した文書に対応
    - 日本語文献と英語文献で異なる設定が可能
    - yomiフィールドの利用で，日本語文献のアルファベット順に並び替えが可能
- typstで使用される`bibliography`関数を使用しないため，CSLファイルによる設定が不要（代わりに`bib_style/bib_setting_custom/bib_setting_〇〇.typ`ファイル内で設定）
- 文中のどこでも引用が可能（`citet`，`citep`関数が利用可能）
- 「アルファベット順並び替え／リスト順」「引用文献のみ／全て表示」「バンクーバー／ハーバード方式表示」の切り替えが可能

> `bib_setting_custom`に追加することで，任意の引用文献スタイルに変更できます


## パッケージの使い方

### Typst Universeを使用する方法

1. 自分のtypstファイルの最初の方に以下を追記
    ```typst
    #import "@preview/enja-bib:0.1.0": *
    #import bib_setting_plain: *
    #show: bib_init
    ```

### フォルダを直接コピーする方法

1. `bib_style`フォルダを自分のディレクトリにコピー
1. 自分のtypstファイルの最初の方に以下を追記
    ```typst
    #import "bib_style/lib.typ": *
    #import bib_setting_plain: *
    #show: bib_init
    ```
1. 自分のtypstファイルの中で文献を挿入したい部分に，`bibliography-list`関数を利用して文献を書く
    ```typst
    #bibliography-list(
        ..bib-file(read("mybib_jp.bib")),
    )
    ```

> 現在すぐに使用可能なスタイル一覧
> - `bib_setting_plain`：bibtexの`jplain`を再現したスタイル
> - `bib_setting_jsme`：日本機会学会の引用を再現したスタイル

## それぞれの関数の使い方

### `bibliography-list`関数

この関数の中に，`bib-tex`関数を入れる．
それぞれの文献ごとにカンマで区切ること．

任意引数
- `lang` : 文献のheadingの言語（`"ja"`：日本語，`"en"`：英語，`none`：表示しない），デフォルトは日本語

### `bib-tex`関数

この中にBibTeXを入れる

> この方法は推奨されません．代わりに`bib-file`関数を利用する方が便利です．

例：
```typst
#bibliography-list(
    bib-tex(`
        @article{Reynolds:PhilTransRoySoc1883,
            author  = {Reynolds, Osborne},
            title   = {An experimental investigation of the circumstances which determine whether the motion of water shall be direct or sinuous, and of the law of resistance in parallel channels},
            journal = {Philosophical Transactions of the Royal Society of London},
            volume  = {174},
            number  = {},
            pages   = {935--982},
            year    = {1883},
            doi     = {10.1098/rstl.1883.0029},
            url     = {https://royalsocietypublishing.org/doi/abs/10.1098/rstl.1883.0029}
        }
    `)
)
```

任意引数
- `lang` : 文献の言語（`"ja"`：日本語，`"en"`：英語，`auto`：自動判別），デフォルトは`auto`

### `bib-item`関数

`bib-tex`関数の代わりに，文献を直書きする

例：
```typst
bib-item(
    label: <Reynolds:PhilTransRoySoc1883>,
    author: "Reynolds",
    year: "1883",
    yomi: "reynolds, o.",
    (
        [Reynolds, O., An experimental investigation of the circumstances which determine whether the motion of water shall be direct or sinuous, and of the law of resistance in parallel channels, Philosophical Transactions of the Royal Society of London (1883],
        [), Vol. 174, pp. 935–982]
    )
)
```

引数
- `label` : ラベル（引用する際には必須）
- `author` : 著者名（引用時・重複判別に用いられる）
- `year` : 年（引用時・重複判別に用いられる）
- `yomi` : 読み（並び替えに用いられる）

### `bib-file`関数

`.bib`形式のファイルを読み込む

例：
```typst
#bibliography-list(
  ..bib-file(read("mybib_jp.bib")),
)
```

> `bib_file`関数は`bib-tex`関数の配列として返すため，`..`の記述が必須であることに注意

### `citet`，`citep`，`citen`関数

文中で引用するときに使用する関数．`@...`のように書いても引用できるが，
```typst
    #citet(<Reynolds:PhilTransRoySoc1883>)
```
のように書くことで引用も可能．
それぞれの関数は，複数の文献入力にも対応（例：`#citet(<Reynolds:PhilTransRoySoc1883>, <Matsukawa:ICFD2022>)`

### `citefull`形式

文中で`citefull`形式を読み込むには
```typst
    @Reynolds:PhilTransRoySoc1883[full]
```
と書く

---

## 独自のスタイルを適用する方法

`bib_setting_plain`や`bib_setting_jsme`以外の独自のスタイルを設定する，或いは一部を変更するには新たに関数を設定します

### 全体設定

```typst
#let bibliography-list(..body) = bib_style.bibliography-list(
  year-doubling,
  bib-sort,
  bib-sort-ref,
  bib-full,
  bib-vancouver,
  vancouver_style,
  bib-year-doubling,
  bib-vancouver-manual,
  ..body
)
```

- `year-doubling`：著者・年が同じ文献がある場合に番号を付与するため，その番号を付与する位置を指定する特殊文字列（`string`型）
- `bib-sort`：アルファベット順にソートを行うか（`bool`型）
- `bib-sort-ref`：引用されている順番にソートを行うか（`bool`型）
- `bib-full`：引用されている文献だけでなく全ての文献を表示するか（`bool`型）
- `bib-vancouver`：vancouverスタイル設定時の番号付け（`string`型）
- `vancouver_style`：vancouverスタイルにするか（`bool`型）
- `bib-year-doubling`：重複著者・年号文献の year-doubling に表示する文字列（`string`型）
- `bib-vancouver-manual`：`bib-vancouver = "manual"`のときの設定

### 参照設定

```typst
#let bib_init(body) = bib_style.bib_init(
  bib-cite,
  bib-citet,
  bib-citep,
  bib-citen,
  body
)
```

- `bib-cite`：citeを設定する配列(`array`型)

  ```typst
  ([], bib-citet-default, [; ], [])
  ```

  **配列の構造**
  1. 参照時の一番最初に出力する文字(`content`型)
  2. 出力する文字列を生成する関数(`function`型)
  3. 2つ以上の文献で，文献間に出力する文字(`content`型)
  4. 参照時の一番最後に出力する文字(`content`型)

  > 上の例では，`Reynolds (1883); Reynolds (1883)`のように出力されます

  2番目の要素である`function`型には，
  - `bib-citet-default`
  - `bib-citep-default`
  - `bib-citen-default`

  が選択できますが，以下のように独自に設定が可能です．
  以下は，`bib-citet-default`の例です．

  ```typst
  #let bib-citet-default(bib_cite_contents) = {
    return bib_cite_contents.at(0) + [~(] + bib_cite_contents.at(1) + [)]
  }
  ```

  **引数**
  1. `bib_cite_contents`：`cite`を構成する要素．
     (著者名, 年号, 引用番号)が入っている

- `bib-citet`, `bib-citep`, `bib-citen`についても，`bib-cite`と同様

### `citet`関数

```typst
#let citet(..label_argument) = bib_style.bib-cite-func(
  bib-citet,
  "citet",
  ..label_argument
)
```

- `bib-citet`：参照設定における`bib-cite`と同様(`function`型)
- `"citet"`：**これは変更しないでください**

### `citep`関数

```typst
#let citep(..label_argument) = bib_style.bib-cite-func(
  bib-citep,
  "citep",
  ..label_argument
)
```

- `bib-citep`：参照設定における`bib-cite`と同様(`function`型)
- `"citep"`：**これは変更しないでください**

### `citen`関数

```typst
#let citen(..label_argument) = bib_style.bib-cite-func(
  bib-citen,
  "citen",
  ..label_argument
)
```

- `bib-citen`：参照設定における`bib-cite`と同様(`function`型)
- `"citen"`：**これは変更しないでください**

### `bibtex`の設定


```typst
#let bib-file(file_contents) = bib_style.bib-file(
  year-doubling,
  bibtex-article-en,
  bibtex-article-ja,
  bibtex-book-en,
  bibtex-book-ja,
  bibtex-booklet-en,
  bibtex-booklet-ja,
  bibtex-inbook-en,
  bibtex-inbook-ja,
  bibtex-incollection-en,
  bibtex-incollection-ja,
  bibtex-inproceedings-en,
  bibtex-inproceedings-ja,
  bibtex-conference-en,
  bibtex-conference-ja,
  bibtex-manual-en,
  bibtex-manual-ja,
  bibtex-mastersthesis-en,
  bibtex-mastersthesis-ja,
  bibtex-misc-en,
  bibtex-misc-ja,
  bibtex-online-en,
  bibtex-online-ja,
  bibtex-phdthesis-en,
  bibtex-phdthesis-ja,
  bibtex-proceedings-en,
  bibtex-proceedings-ja,
  bibtex-techreport-en,
  bibtex-techreport-ja,
  bibtex-unpublished-en,
  bibtex-unpublished-ja,
  bib-cite-author,
  bib-cite-year,
  file_contents
)
```

- `year-doubling`：全体設定と同様（`string`型）
- `bibtex-...`：各フィールドの設定（`array`型）

    **命名規則**

    `bibtex-(フィールド名)-(言語)`

    **例**

    ```typst
    #let bibtex-article-en = (
        ("author", (none,"",author-set3, "", ". ", (), ".")),
        ("title", (none,"",title-en, "", ". ", (), ".")),
        ("journal", (none,"",all-emph, "", ", ", (), ".")),
        //...出力する項目を順に並べる
    )
    ```

    - 各配列は，出力する項目の順に並べる（上の例では，`author`，`title`，`journal`の順に出力される）
    - `bibtex`内に無い項目は飛ばされる（上の場合，`title`の項目が`bibtex`内にない場合は`author`と`journal`のみが出力される）
    - `bibtex`内にあっても，配列の中に含まれない場合は出力されない（上の例では，`author`，`title`，`journal`のみ出力される）

    **各項目の書き方**

    ```typst
    ("author", (none,"",author-set3, "", ". ", (), "."))
    ```

    1. 項目名（`string`型）
    2. 出力形式を決定する配列（`array`型）

        1. 1つ前の項目がAのとき，前の語尾文字列を削除して置き換える先頭文字列（`content`,`string`型）
        2. 必ず出力される文字列（`content`,`string`型）
        3. 出力される文字列を出力する関数（`function`型）
        4. 最後でない限り必ず出力される語尾文字列（`content`,`string`型）
        5. 1つ後の項目のAに書かれていない，かつ最後でない場合に出力される語尾文字列（`content`,`string`型）
        6. 場合A（`array`型）
        7. 最後の場合に出力される文字列（`content`,`string`型）

- `bib-cite-author`：`cite`の`author`を返す関数（`function`型）

- `bib-cite-year`：`cite`の`year`を返す関数（`function`型）

`bib-tex`も同様に設定する

```typst
#let bib-tex(..body) = bib_style.bib-tex(
  year-doubling,
  bibtex-article-en,
  bibtex-article-ja,
  bibtex-book-en,
  bibtex-book-ja,
  bibtex-booklet-en,
  bibtex-booklet-ja,
  bibtex-inbook-en,
  bibtex-inbook-ja,
  bibtex-incollection-en,
  bibtex-incollection-ja,
  bibtex-inproceedings-en,
  bibtex-inproceedings-ja,
  bibtex-conference-en,
  bibtex-conference-ja,
  bibtex-manual-en,
  bibtex-manual-ja,
  bibtex-mastersthesis-en,
  bibtex-mastersthesis-ja,
  bibtex-misc-en,
  bibtex-misc-ja,
  bibtex-online-en,
  bibtex-online-ja,
  bibtex-phdthesis-en,
  bibtex-phdthesis-ja,
  bibtex-proceedings-en,
  bibtex-proceedings-ja,
  bibtex-techreport-en,
  bibtex-techreport-ja,
  bibtex-unpublished-en,
  bibtex-unpublished-ja,
  bib-cite-author,
  bib-cite-year,
  ..body
)
```

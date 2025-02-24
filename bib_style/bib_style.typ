
#import "bib_tex.typ": *

// --------------------------------------------------
//  INITIALIZATION
// --------------------------------------------------

#let bib-cite-turn = state("bib-cite-turn", ())
#let bib-output-list

#let bib_brace_l = text(weight: "regular")[{]
#let bib_brace_r = text(weight: "regular")[}]

#let bib_init(body) = {
  show ref: it =>{

      if it.has("element") and it.element != none{
        if it.element.has("kind") and it.element.kind == "bib"{

          let cite-arr = eval(it.element.supplement.text)

          bib-cite-turn.update(bib_info => {
            let output_arr = bib_info
            let add_num = cite-arr.at(2)
            if output_arr.contains(add_num) == false{
              output_arr.push(add_num)
            }
            output_arr
          })

          cite-arr = (cite-arr.at(0), cite-arr.at(1), cite-arr.at(3))

          if it.supplement == [citet]{//citetのとき
            bib-citet.at(1)(cite-arr)
          }
          else if it.supplement == [citep]{//citepのとき
            bib-citep.at(1)(cite-arr)
          }
          else if it.supplement == [citen]{//citenのとき
            bib-citen.at(1)(cite-arr)
          }
          else if it.supplement == auto{//その他
            bib-cite.at(0) + link(it.target, bib-cite.at(1)(cite-arr)) + bib-cite.at(3)
          }
          else{//supplementが指定されているとき
            link(it.target, it.supplement)
          }

        }
        else{
          it
        }
      }
      else{
        it
      }
  }
  body
}



#let from_content_to_output(content_raw) = {

  let contents = content_raw.pos()

  // ----- ソートする場合 ----- //
  if bib-sort{
    let yomi_arr = ()//yomiの配列
    let num = 0//番号
    for value in contents{//各文献ごとにyomi_arrに追加
      yomi_arr.push((value.at(2), num))
      num += 1
    }
    yomi_arr = yomi_arr.sorted()//yomi_arrをソート
    let sorted_contents = ()//ソートされた文献の配列
    for value in yomi_arr{//yomi_arrの順番にcontentsをソート
      sorted_contents.push(contents.at(value.at(1)))
    }
    contents = sorted_contents//contentsをソートされたものに変更
  }


  for value in range(contents.len()){
    contents.at(value).push(value)
  }

  // ----- 出力 ----- //

  context {
    let bib-cite-turn-arr = bib-cite-turn.final()
    if bib-cite-turn-arr == (){//もし何も引用されてなければ，全ての文献を表示する
      bib-cite-turn-arr = range(contents.len())
    }

    // ----- 文献番号をリストに変換 ----- //

    let output_contents = ()
    if bib-sort-ref{//引用された順番に文献を出力
      for value in bib-cite-turn-arr{
        output_contents.push(contents.at(value))
      }
    }
    else{
      if bib-full{
        for value in range(contents.len()){
          output_contents.push(contents.at(value))
        }
      }
      else{
        bib-cite-turn-arr = bib-cite-turn-arr.sorted()
        for value in bib-cite-turn-arr{
          output_contents.push(contents.at(value))
        }
      }
    }

    if bib-full and bib-sort-ref{//全文献を出力
      let num = 0
      for value in contents{
        if bib-cite-turn-arr.contains(num) == false{
          output_contents.push(value)
        }
        num += 1
      }
    }

    // ----- 重複文献に記号を挿入 ----- //

    if vancouver_style == false{//ハーバード方式のとき
      let cite-arr = ()
      for value in output_contents{
        cite-arr.push(value.at(1).join(", "))
      }
      let num = 0
      for value in cite-arr{
        let num2 = num + 1
        let double_arr = ()
        for value2 in cite-arr.slice(num2){
          if value == value2{
            double_arr.push(num2)
          }
          num2 += 1
        }

        if double_arr != (){//重複があるとき

          double_arr.insert(0, num)
          let num2 = 1

          for value2 in double_arr{
            let add_character = numbering(bib-year-doubling, num2)
            output_contents.at(value2).at(0).insert(1, (add_character, ))
            output_contents.at(value2).at(1).at(1) = output_contents.at(value2).at(1).at(1) + add_character
            num2 += 1
          }
        }

        num += 1
      }
    }

    // ----- リストを出力形式に変換 ----- //

    let num = 1
    let output_bib = ()

    if vancouver_style and bib-vancouver != "manual"{
      for value in output_contents{
        let cite-arr = value.at(1)
        cite-arr.push(value.at(4))
        cite-arr.push(num)
        output_bib.push([+ #figure(value.at(0).sum().sum(), kind: "bib", supplement: [#cite-arr])#value.at(3)])

        num += 1
      }
    }
    else{
      let bibnum = output_contents.len()
      for value in output_contents{
        let cite-arr = value.at(1)
        cite-arr.push(value.at(4))
        cite-arr.push(num)
        output_bib.push([#figure(value.at(0).sum().sum(), kind: "bib", supplement: [#cite-arr])#value.at(3)])

        num += 1
      }
    }

    // ----- 出力 ----- //

    if vancouver_style{
      if bib-vancouver == "manual"{
        let output_bib2 = ()
        let cite-arr = ()
        for index in range(num - 1){
          cite-arr = (output_contents.at(index).at(1))
          cite-arr.push(index)
          output_bib2.push(bib-vancouver-manual(cite-arr))
          output_bib2.push(output_bib.at(index))
        }

        table(
          columns: (auto, auto),
          rows: auto,
          gutter: (),
          column-gutter: (),
          row-gutter: (),
          align: (left, left),
          stroke: none,
          fill: none,
          inset: 0% + 5pt,
          ..output_bib2
        )
      }
      else{
        set enum(numbering: bib-vancouver)
        output_bib.sum()
      }
    }
    else{
      set par(hanging-indent: 2em)
      output_bib.sum()
    }
  }

}

// --------------------------------------------------
//  MAIN FUNCTION
// --------------------------------------------------

//メイン関数
#let bibliography-list(lang: "ja", ..body) = {

  if lang == "ja"{
    heading("文　　　献", numbering: none)
  }
  else if lang == "en"{
    heading("References", numbering: none)
  }
  set par(first-line-indent: 0em)
  set par(leading: 1em)

  show figure.where(kind: "bib"): it =>{
    align(left, it)
  }

  let bib_content = body
  from_content_to_output(bib_content)
}

// ---------- 文献形式に出力する関数 ---------- //
#let bib-tex(it, lang: auto) = {
  let dict = bibtex_to_dict(it)
  let dict = add_dict_lang(dict, lang)

  let output_arr = ()
  output_arr.push(bibtex-to-bib(dict, get_element_function(dict)))
  output_arr.push(bibtex-to-cite(dict))
  output_arr.push(bibtex-yomi(dict, output_arr.at(0)))
  output_arr.push(dict.label)

  return output_arr
}

#let bib-item(it, author: "", year: "", yomi: none, label: none) = {

  let output_arr = ()
  let bib_str = ""
  if type(it) == content or type(it) == str{
    output_arr.push(((it, ),))
    if type(it) == content{
      bib_str = contents-to-str(it)
    }
    else{
      bib_str = it
    }
  }
  else{
    let output_bib = ()
    for v in it{
      output_bib.push((v, ))
    }
    output_arr.push(output_bib)
    bib_str = it.sum()
    if type(bib_str) == content{
      bib_str = contents-to-str(bib_str)
    }
  }

  output_arr.push((author, year))
  if yomi == none{
    output_arr.push(bib_str)
  }
  else{
    output_arr.push(yomi)
  }
  output_arr.push(label)

  return output_arr
}

#let bib-file(file_contents) = {

  let file_arr = file_contents.children

  let output-arr = ()
  let tmp = ()

  for value in file_arr {
    if value.func() == ref{
      if tmp != () {
        if tmp.at(0).target != <comment>{
          output-arr.push(bib-tex[#tmp.sum()])
        }
      }
      tmp = (value,)
    }
    else if value == parbreak(){
    }
    else{
      tmp.push(value)
    }
  }

  if tmp.at(0).target != <comment>{
    output-arr.push(bib-tex[#tmp.sum()])
  }

  return output-arr
}

// --------------------------------------------------
//  CITE FUNCTION
// --------------------------------------------------

#let citet(..label_argument) = {
    let label_arr = label_argument.pos()
    if label_arr.len() == 1{//ラベルが1つのとき

      let label = label_arr.at(0)
      return bib-citet.at(0) + link(label,ref(label, supplement: "citet")) + bib-citet.at(3)

    }else{//ラベルが2つ以上のとき

      let tmp = label_arr.remove(0)
      let output1 = bib-citet.at(0) + link(tmp,ref(tmp, supplement: "citet")) + bib-citet.at(2)
      tmp = label_arr.remove(-1)
      let output2 = link(tmp,ref(tmp, supplement: "citet")) + bib-citet.at(3)
      let output = ""
      for label in label_arr{
        output += link(label,ref(label, supplement: "citet")) + bib-citet.at(2)
      }
      return output1 + output + output2

    }
}

#let citep(..label_argument) = {
    let label_arr = label_argument.pos()
    if label_arr.len() == 1{//ラベルが1つのとき

      let label = label_arr.at(0)
      return bib-citep.at(0) + link(label,ref(label, supplement: "citep")) + bib-citep.at(3)

    }else{//ラベルが2つ以上のとき

      let tmp = label_arr.remove(0)
      let output1 = bib-citep.at(0) + link(tmp,ref(tmp, supplement: "citep")) + bib-citep.at(2)
      tmp = label_arr.remove(-1)
      let output2 = link(tmp,ref(tmp, supplement: "citep")) + bib-citep.at(3)
      let output = ""
      for label in label_arr{
        output += link(label,ref(label, supplement: "citep")) + bib-citep.at(2)
      }
      return output1 + output + output2

    }
}

#let citen(..label_argument) = {
    let label_arr = label_argument.pos()
    if label_arr.len() == 1{//ラベルが1つのとき

      let label = label_arr.at(0)
      return bib-citen.at(0) + link(label,ref(label, supplement: "citen")) + bib-citen.at(3)

    }else{//ラベルが2つ以上のとき

      let tmp = label_arr.remove(0)
      let output1 = bib-citen.at(0) + link(tmp,ref(tmp, supplement: "citen")) + bib-citen.at(2)
      tmp = label_arr.remove(-1)
      let output2 = link(tmp,ref(tmp, supplement: "citen")) + bib-citen.at(3)
      let output = ""
      for label in label_arr{
        output += link(label,ref(label, supplement: "citen")) + bib-citen.at(2)
      }
      return output1 + output + output2

    }
}

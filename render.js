// UI stuff
window.onload = function() {

var generateButton = document.getElementById("generateButton");
generateButton.addEventListener("click", function () {
  source = document.getElementById('predicates').value;
  var generated = generate(); 
  document.getElementById("generated").innerHTML = "<pre>"+generated+"</pre>";
});

document.getElementById('predicates').innerHTML = source;
// document.getElementById('fileinput').addEventListener('change', readFileAndDisplay, false);
}

// Parsing ASP predicates
//

function extract_outer_parens(s) {

  let seen_open_paren = false;
  let inside_parens = 0;
  let left = "";
  let right = "";
  let inner = "";

  for(let i=0; i<s.length; i++) {

    
    if(s[i] == ")") {
      inside_parens--;
    }

    if(inside_parens > 0) {
      inner += s[i];
      if(s[i] == "(") {
        inside_parens++;
      }
    } else {
      if(s[i] == ")")
        continue;
      if(s[i] == "(") {
        seen_open_paren = true;
        inside_parens++;
        continue;
      }

      if(seen_open_paren)
        right += s[i];
      else
        left += s[i];
  
    }
  }

  return {left:left, inner:inner, right:right}
}


// want to take a thing of the form s1, ..., sn
// where the internal si's might themselves have commas inside parens...
// and just return the list [s1, ..., sn]
function extract_outer_csv(csv_string) {
  
  let s = csv_string;
  let inside_parens = 0;
  let current_token = "";
  let values = [];

  for(let i=0; i<s.length; i++) {
    if(s[i] == "(") {
      //console.log("open paren detected at position "+i);
      inside_parens++;
    }

    if(inside_parens > 0) {
      //console.log("i'm inside parens");
      current_token += s[i];
      if(s[i] == ")") {
        inside_parens--;
        if(inside_parens == 0) {
          // end of token
          values.push(current_token);
          current_token = "";
        }
      }
    } else { // we're NOT inside parens, so commas count!
      if(s[i] == ",") {
        //console.log("comma detected");
        values.push(current_token);
        current_token = "";
      } else {
        //console.log(s[i] + " is not a comma")
        current_token += s[i];
      }
    }
  }
  values.push(current_token);

  return values;
}

function parse_term(term_s) {
  // term_s is if the form "p(arg1, ..., argn)"
  // where each arg_i is either a string or another nested term
  // that can recursively be parsed with parse_term
  //
  // Want to return
  // {name: string, args: term list}

  let {left, inner, right} = extract_outer_parens(term_s);
  // right should be ""
  // left is just the predicate name
  // inner is a csv list of terms to recursively parse into args

  let name = left;
  let args = [];

  if(inner == "") {
    return name;
  }

  let inner_strings = extract_outer_csv(inner);

  // Recursively parse each comma-separated term
  for(let i=0; i < inner_strings.length; i++) {
    let parsed = parse_term(inner_strings[i]);
    args.push(parsed);
  }

  return {name:name, args:args}
}


function parse_answer_set(s) {
  var pred_strings = s.split(" ");
  var preds = [];

  for(let i=0; i<pred_strings.length; i++) {
    preds.push(parse_term(pred_strings[i]));
  }

  return preds;
}

// This only prints the leaves of the syntax tree
// So e.g. seq(seq(a, b), c, seq(d, seq(e)))
// would get printed as "a b c d e"
// (where " " is used as a separator)
function ast_leaves(term, separator) {
  if(term.args == undefined)
    return term;

  else if(term.args.length == 0)
    return term.name;

  // At least 1 arg
  else { // Just print the args, not the name of the term
    term_string = "";
    for(let i=0; i<term.args.length; i++) {
      // recursive call
      term_string += ast_leaves(term.args[i], separator);
      if(i < term.args.length-1)
        term_string += separator
    }
    return term_string;
  }
}



function atoms_to_lines(atoms) {
  var lines = [];
  var nlines = 0;
  for (var i = 0; i < atoms.length; i++) {
    var p = atoms[i].name;
    if (p == "output") {
      nlines++;
      var line_term = atoms[i].args[0];
      if (line_term != "" && line_term != " ")
        lines.push(ast_leaves(line_term, " "));
    }
  }
  console.log("Parsed " + nlines + " lines of output");
  return lines;
}


var source = "output(seq(seq(the,transformation),seq(touch,seq(her,limbs)))) output(seq(seq(his,transformation),seq(touch,seq(the,limbs)))) output(seq(seq(his,transformation),seq(touch,seq(a,limbs)))) output(seq(seq(her,transformation),seq(touch,seq(his,limbs)))) output(seq(seq(her,transformation),seq(touch,seq(their,limbs)))) output(seq(seq(her,transformation),seq(touch,seq(the,limbs)))) output(seq(she,seq(unfurl,seq(into,seq(the,transformation))))) output(seq(they,seq(unfurl,seq(into,seq(the,transformation)))))"


/* Generate something same size as the source, starting from the same word
 * as the source. */
function generate () {

  let atoms = parse_answer_set(source);
  let lines = atoms_to_lines(atoms);

  return lines.join("<br>");

}




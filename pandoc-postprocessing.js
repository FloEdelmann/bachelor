#!/usr/bin/env node

'use strict';

const fs = require('fs');
const process = require('process');

const path = process.argv[2];

let content = fs.readFileSync(path, 'utf8');

// allow midrules in multiline tables with ###
content = content.replace(/\\begin\{minipage\}.*?\n(?:\\#){3,}(?:.|\n)+?\\end\{minipage\}\\tabularnewline/g, '\\midrule');

// give inline code a gray background + special handling for #tbl:calc-sampling-pos
content = content.replace(/\\lstinline!(.*?)!/g, (substring, code) => {
  if (code.match(/^(_*)↑(_*)$/)) {
    return `\\small\\verb!${' '.repeat(RegExp.$1.length)}↑${' '.repeat(RegExp.$2.length)}!`;
  }

  return `\\colorbox{WhiteSmoke}{\\lstinline!${code}!}`;
});

// allow arraystrech to be set for each table individually
content = content.replace(/(\\begin\{longtable\}[^\n]+\n\\caption\{(?:\\label\{[^{}]+\})?)arraystretch=([0-9.]+)\s+((?:.|\n)+?\\end\{longtable\})/g, `{
\\renewcommand{\\arraystretch}{$2}
$1$3}`);

// cut off longer caption links before first "." in list of figures / tables
content = content.replace(/\\caption\{(\\label\{[^{}]+\})?([^.{}]+|(?:[^.{}]*\{[^{}]*\}[^.{}]*)*)(\.(?:[^{}]*|(?:[^{}]*\{[^{}]*\}[^{}]*)*))\}/gm, '\\caption[$2]{$1$2$3}');

// prevent glsadd from adding a paragraph on its own
content = content.replace(/^(\\glsadd(?:\[[^\]]*?\])?\{[^}]+?\})$/gm, '$1\\vspace{-1.2\\baselineskip}');

// make links to chapters work
content = content.replace(/^\\hypertarget\{([^}]+?)\}\{\\chapter/gm, '\\cleardoublepage\\hypertarget{$1}{\\chapter');

// make TODOs more visible:
content = content.replace(/\\emph\{(\\textbf\{TODO:\} [^}]+)\}/g, '\\colorbox{yellow}{$1}');

fs.writeFileSync(path, content, 'utf8');

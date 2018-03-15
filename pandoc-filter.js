#!/usr/bin/env node

'use strict';

const pandoc = require('pandoc-filter');
const {RawInline, Image} = pandoc;

function customReplace(type, value, format, meta) {
  if (format === 'plain' && type === 'Emph') {
    // remove emphasize for txt output
    return value;
  }

  if (format !== 'latex') {
    return;
  }

  if (type === 'Str') {
    return stringReplace(value);
  }

  // link to PDF images instead of SVG ones
  if (type === 'Image') {
    const [attrs, alt, [src, title]] = value;
    return Image(attrs, alt, [src.replace('.svg', '.pdf'), title]);
  }
}


function stringReplace(value) {
  let changed = false;

  // replace :x: and :ok: with their corresponding, colored unicode symbols
  if (value.match(/:x:|:ok:|:oksw:/)) {
    value = value.replace(/:x:/g, '\\textcolor{FireBrick}{\\ding{55}}');
    value = value.replace(/:ok:/g, '\\textcolor{ForestGreen}{\\ding{51}}');
    value = value.replace(/:oksw:/g, '\\ding{51}');
    changed = true;
  }

  // replace ↩ with latex newline (especially useful in multiline tables)
  if (value.includes('↩')) {
    value = value.replace('↩', '\\\\\n');
    changed = true;
  }

  if (changed) {
    return RawInline('latex', value);
  }
}

pandoc.stdio(customReplace);

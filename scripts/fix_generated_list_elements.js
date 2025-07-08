const fs = require('fs');
const path = require('path');

// Fix generated list element files
function fixGeneratedFiles() {
  const codeGenPath = path.join(__dirname, '..', 'bridge', 'code_gen');
  
  const fixes = [
    {
      files: ['qjs_html_li_element.cc', 'qjs_html_li_element.h'],
      replacements: [
        { from: /QJSHTMLLiElement/g, to: 'QJSHTMLLIElement' },
        { from: /HTMLLiElement/g, to: 'HTMLLIElement' },
        { from: /"HTMLLiElement"/g, to: '"HTMLLIElement"' },
        // Don't replace kHTMLLiElement - it's correct as is
      ]
    },
    {
      files: ['qjs_html_ulist_element.cc', 'qjs_html_ulist_element.h'],
      replacements: [
        { from: /QJSHTMLUlistElement/g, to: 'QJSHTMLUListElement' },
        { from: /HTMLUlistElement/g, to: 'HTMLUListElement' },
        { from: /"HTMLUlistElement"/g, to: '"HTMLUListElement"' },
        { from: /JS_CLASS_HTML_ULIST_ELEMENT/g, to: 'JS_CLASS_HTML_UL_ELEMENT' },
        { from: /kHTMLUlistElement/g, to: 'kHTMLUListElement' }
      ]
    },
    {
      files: ['qjs_html_olist_element.cc', 'qjs_html_olist_element.h'],
      replacements: [
        { from: /QJSHTMLOlistElement/g, to: 'QJSHTMLOListElement' },
        { from: /HTMLOlistElement/g, to: 'HTMLOListElement' },
        { from: /"HTMLOlistElement"/g, to: '"HTMLOListElement"' },
        { from: /JS_CLASS_HTML_OLIST_ELEMENT/g, to: 'JS_CLASS_HTML_OL_ELEMENT' },
        { from: /kHTMLOlistElement/g, to: 'kHTMLOListElement' }
      ]
    }
  ];
  
  console.log('Fixing generated list element files...');
  
  for (const fix of fixes) {
    for (const file of fix.files) {
      const filePath = path.join(codeGenPath, file);
      if (fs.existsSync(filePath)) {
        let content = fs.readFileSync(filePath, 'utf8');
        for (const replacement of fix.replacements) {
          content = content.replace(replacement.from, replacement.to);
        }
        fs.writeFileSync(filePath, content);
        console.log(`Fixed ${file}`);
      }
    }
  }
  
  console.log('Done fixing generated files');
}

// Run the fix
fixGeneratedFiles();
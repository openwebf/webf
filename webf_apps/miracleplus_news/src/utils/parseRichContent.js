export function parseRichContent(content) {
    try {
        const parsed = JSON.parse(content);
        // TODO: simple parse for text content
        return parsed.map(block => {
            if (block.type === 'paragraph') {
                return block.children.map(child => child.text).join('');
            }
            return '';
        }).join('\n');
    } catch (e) {
        return content;
    }
}

export function formatToRichContent(text) {
    const paragraphs = text.split('\n').filter(p => p.trim());

    const richContent = paragraphs.map(paragraph => ({
        type: 'paragraph',
        children: [{
            type: 'text',
            text: paragraph
        }]
    }));

    return JSON.stringify(richContent);
}

export function checkIsRichContent(content) {
    try {
        JSON.parse(content);
        return true;
    } catch (e) {
        return false;
    }
}
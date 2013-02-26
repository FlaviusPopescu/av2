% Mocco is a quick-and-dirty, literate-programming-style documentation 
% generator. It is a Matlab port of [Docco](http://jashkenas.github.com/docco/),
% which was written by [Jeremy Ashkenas](https://github.com/jashkenas) in
% in Coffescript and runs on node.js.
%
% Mocco produces HTML that displays your comments alongside your code. 
% Comments are passed through [MarkdownJ](http://daringfireball.net/projects/markdown/syntax), 
% and code is highlighted using Python's syntax highlighting tool 
% [Pygments](http://pygments.org/) This page is the result of running Mocco 
% against its own source files.
%
% To run Mocco, you'll have to have installed Python and Pygments. 
% It also depends on [MarkdownJ](http://markdownj.org/) the Java port to
% Markdown.
%
% This version of Mocco only works for Matlab files.
%
% To use Mocco, run it from Matlab:
%
%   Mocco('some directory')
%
%...will generate linked HTML documentation for the named source files, 
% saving it into a <code>docs</code> folder.
%
%The source for Nocco is available on GitHub, and released under the MIT license.
%
% If **Matlab** isn't your cup of tea, or you'd prefer a more convenient
% package, get [Rocco](http://rtomayko.github.com/rocco/), the **Ruby** port that's
% available as a gem. If you're writing shell scripts, try
% [Shocco](http://rtomayko.github.com/shocco/), a port for the **POSIX shell**.
% Both are by [Ryan Tomayko](http://github.com/rtomayko). If **Python**'s more
% your speed, take a look at [Nick Fitzgerald](http://github.com/fitzgen)'s
% [Pycco](http://fitzgen.github.com/pycco/).
% ### Main Document Generation Functions
function Mocco(targetFolder)
    set(0,'RecursionLimit', 5000) 
    moccoLocation = mfilename('fullpath');
    moccoLocation = moccoLocation(1:end-5);
    
    javaaddpath([moccoLocation '/Resource/markdownj-1.0.2b4-0.3.0.jar']);
    import com.petebevin.markdown.MarkdownProcessor.*;
    
    global HTML_TEXT
    global MOCCO_DIR
    global TARGET_DIR
    global JUMP_HTML
    MOCCO_DIR  = moccoLocation;
    TARGET_DIR = targetFolder;
    HTML_TEXT  = GetHTMLFiles();
    
    if(size(targetFolder) > 0)
        cd(targetFolder);
        if ~isdir('report/docs'); mkdir('report/docs'); end;
        cd('report/docs');
        copyfile([GetResourceFolder() '*'], pwd, 'f');
    end
        
    files     = GetMFiles(targetFolder);
    JUMP_HTML = GenerateJump(files);
    
    cellfun(@GenerateDocumentation, files);
    cd(targetFolder);
end

function GenerateDocumentation(file)
    tokens   = Parse(file);
    sections = Highlight(tokens);
    GenerateHTML(file, sections);
end

function tokens = Parse(file)
    lines    = GetLines(file);
    tokens   = { };
    token    = @(docs, code) struct('DocsText', docs, 'CodeText', code);
    language = GetLanguage(GetCommentSymbol());
    hasCode  = 0;
    docsText = [];
    codeText = [];
    
    for lineIdx = 1:length(lines)
        line = lines{lineIdx};
        if(~isempty(regexp(line, language.commentMatcher, 'once')) && isempty(regexp(line, language.commentFilter, 'once')))
            if(hasCode)
                tokens   = cat(1, tokens, token(docsText, codeText));
                hasCode  = 0;
                docsText = [];
                codeText = [];
            end
            docsText = [docsText regexprep(line, language.commentMatcher, '')];
        else
            hasCode  = 1;
            codeText = char([codeText, line]);
        end
    end
    tokens = cat(1, tokens, token(docsText, codeText));
end

function sections = Highlight(tokens)
    %This function process the code segment of a section in Pygment and the
    %doc segment of a section in markdown. It calls Pygment from Python
    %directly and uses the markdownj, a java port of markdown.
    global HTML_TEXT
    
    m = com.petebevin.markdown.MarkdownProcessor();
    
    language = GetLanguage(GetCommentSymbol());
    
    % Create Pygmentize Codes
    codeTexts = cellfun(@(token) token.CodeText, tokens, 'UniformOutput', 0);
    codeTexts = foldl(@(code1, code2) [char(code1) char(language.divider_text) char(code2)], hd(codeTexts), tl(codeTexts));
    codeHtmls = Pygmentize('matlab', codeTexts);
    codeHtmls = strrep(codeHtmls, '\', '\\')
    codeHtmls = strrep(strrep(codeHtmls, HTML_TEXT.HighlightStart, ''), HTML_TEXT.HighlightEnd, '');
    codeHtmls = regexp(codeHtmls, language.divider_html, 'split');
    codeHtmls = cellfun(@(codeHtml) [char(HTML_TEXT.HighlightStart) char(codeHtml) char(HTML_TEXT.HighlightEnd)], codeHtmls, 'UniformOutput', 0)';
    codeHtmls{1}
    
    % Create Markdown Documents
    %docsHtmls = cellfun(@(token) char(m.markdown(char(token.DocsText))), tokens, 'UniformOutput', 0);
    docsHtmls = cellfun(@(token) char(token.DocsText), tokens, 'UniformOutput', 0);
    
    % Create sections
    sections = cellfun(@(code, docs) struct('DocsHtml', docs, 'CodeHtml', code), codeHtmls, docsHtmls, 'UniformOutput', 0);
end

function GenerateHTML(file, sections)
    global HTML_TEXT
    global JUMP_HTML
    if ~isdir(GetOutputDirectory())
        error('Output Directory has not been created');
    end

    title = GetRelativeFileName(file);
    dest  = GetOutputFile(file);

    fid = fopen(dest, 'w');
    fwrite(fid, strrep(strrep(HTML_TEXT.Header, '?title', title), '?jump', JUMP_HTML));
    for idx = 1:length(sections)
        T  = regexprep(HTML_TEXT.TableEntry, '?index', int2str(idx));
        T1 = regexprep(T,'?docs_html',  sections{idx}.DocsHtml);
        T2 = regexprep(T1,'?code_html', sections{idx}.CodeHtml);
        fwrite(fid, T2);
    end
    fclose(fid);
end

function str = GenerateJump(files)
    global HTML_TEXT
    jumpEntry   = @(file) regexprep(regexprep(HTML_TEXT.Jump, '?jump_html', GetOutputFile(file)), '?jump_file', GetRelativeFileName(file));
    jumpEntries = cellfun(jumpEntry, files, 'UniformOutput', 0);
    jumpString  = foldr(@(jump1, jump2) [char(jump1) char(jump2)], hd(jumpEntries), tl(jumpEntries));
    str = [char(HTML_TEXT.JumpStart) char(jumpString(1)) char(HTML_TEXT.JumpEnd)];
end

function comment = GetCommentSymbol()
    comment = '%';
end

% Not used yet, would like to turn this into a markdown section like '###'
function section = GetSectionSymbol()
    section = '%%';
end

function language = GetLanguage(symbol)
    language.commentMatcher = ['^\s*' symbol '\s?'];
    language.commentFilter  = '(^#![/]|^\s*#\{)';
    language.divider_text   = [char(10) symbol 'DIVIDER' char(10)];
    %language.divider_html   = [char(10) '*<span class="c[1]?">' symbol 'DIVIDER</span>' char(10) '*'];
    language.divider_html   = [char(10) '\\\\PY{c}{\\\\PYZpc{}DIVIDER}' char(10)];
    
end

% ### File and Foler IO Helpers
function resourceFolder = GetResourceFolder()
    global MOCCO_DIR
    resourceFolder = [MOCCO_DIR '/Resource/'];
end

function htmlFolder = GetHTMLFolder()
    global MOCCO_DIR
    htmlFolder = [MOCCO_DIR '/Resource/HTML/'];
end

function htmls = GetHTMLFiles()
    r = dir(GetHTMLFolder());
    for i = 1:size(r, 1)
        if(strcmp(r(i).name, '.') || strcmp(r(i).name, '..')); continue; end;
        fieldName = r(i).name;
        fieldName = fieldName(1:strfind(fieldName, '.') - 1);
        htmls.(fieldName) = foldl(@(line1, line2) [char(line1) char(10) char(line2)], [], GetLines([GetHTMLFolder() r(i).name]));
    end
end

function files = GetMFiles(directory)
    files = {};
    r = dir(directory);
    for i = 1:size(r, 1)
        if isdir(r(i).name); continue; end;
        if ~strcmp(r(i).name(length(r(i).name) - 1:end), '.m'); continue; end;
        files = cat(1, files, [directory '/' r(i).name]);
    end
end

function fileName = GetRelativeFileName(file)
    global TARGET_DIR
    fileName = strrep(file, [TARGET_DIR '/'], '');
end

function lines = GetLines(file)
    fid = fopen(file);
    lines = {};
    nline = fgets(fid);
    while ischar(nline)
        lines = cat(1, lines, nline);
        nline = fgets(fid);
    end
    fclose(fid);
end

function outputDir = GetOutputDirectory()   
    global TARGET_DIR
    outputDir = [TARGET_DIR '/report/docs'];
end

function outputFileName = GetOutputFile(file)
    global TARGET_DIR
    outputFileName = [strrep(file(1:strfind(file, '.')-1), TARGET_DIR, GetOutputDirectory()) '.html'];
end

% ### Pygmentize Helpers.
function str = Pygmentize(lang, code)
    function file = GetTempFile()
        file = sprintf('%s_%s_%s.txt', int2str(now), int2str(rem(now, 2)*1000), lang);
        fid = fopen(file, 'w');
        try
            fwrite(fid, code{1});
        catch e
            fwrite(fid, code);
        end
        fclose(fid);
    end
    tempFile = GetTempFile();
    str = evalc(['!PYGMENTIZE -l ' lang ' -O encoding=utf-8 -f latex ' tempFile]);
    delete(tempFile);
end

% ### Functional Programming Helpers
function handle = ifthenelse(b, varargin)
    handle = varargin{2-b}();
end

function handle = Y(f)
    % Y-Combinator
    handle = feval(@(g)g(g), @(h)f(@(varargin) feval(h(h), varargin{:}))); 
end

function head = hd(xs)
    head = ifthenelse(isempty(xs), @()[], @()xs(1));
end

function tail = tl(xs)
    tail = ifthenelse(length(xs) <= 1, @()[], @()xs(2:end));
end

function folded = foldr(fxn, xn,   xs) 
    folded = feval(Y(@(fold) @(xt) ifthenelse(isempty(xt), @() xn, @() fxn(hd(xt), fold(tl(xt))))), xs);
end

function folded = foldl(fxn, x0,   xs) 
    folded = feval(Y(@(fold) @(xp, xt) ifthenelse(isempty(xt), @() xp, @() fold(fxn(xp, hd(xt)), tl(xt)))), x0, xs);
end


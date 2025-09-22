\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{1ssmeeting}

\LoadClass[11pt]{article}

% \usepackage[a4paper,
%             top=-1cm,
%             bottom=2cm,
%             right=2cm,
%             left=2cm]{geometry}

\setlength{\topmargin}{2cm}
\setlength{\textwidth}{16cm}
\setlength{\textheight}{21.0cm}
\setlength{\oddsidemargin}{0.65cm}
\setlength{\evensidemargin}{0.65cm}

\renewenvironment{abstract}
{\begin{list}{}{%
  \setlength{\rightmargin}{0.5cm}
  \setlength{\leftmargin}{0.5cm}
  \small} 
  \item[] }
{\end{list}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\ps@headreport}
{ \renewcommand{\@oddhead} % cabeçalho
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\vspace{-2.00cm}
%\includegraphics[scale = 1.34]{cabeçalho.pdf}
\includegraphics[width=1\textwidth]{cabecalho1.jpeg}
\vspace{0.50cm}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\rule{\textwidth}{0.16pt} 
  \renewcommand{\@oddfoot}{}
  \renewcommand{\@evenhead}{\@oddhead}
  \renewcommand{\@evenfoot}{\@oddfoot}
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand\criartitulo{\par
  \begingroup
    \renewcommand\thefootnote{\@arabic\c@footnote}%
    \def\@makefnmark{\rlap{\@textsuperscript{\normalfont\@thefnmark}}}%
    \long\def\@makefntext##1{\parindent 0em\noindent
            \hb@xt@1.2em{%
                \hss\@textsuperscript{\normalfont\@thefnmark}}##1}%
      
      \newpage
      \global\@topnum\z@   % Prevents figures from going at top of page.
      \@criartitulo

    \thispagestyle{headreport}\@thanks
     \endgroup
  \global\let\thanks\relax
  \global\let\criartitulo\relax
  \global\let\@criartitulo\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}
\def\@criartitulo{%
  \newpage
  \null
  \vspace{-7em}%
  \begin{center}%
  \let \footnote \thanks
    {\LARGE \@title \par}%
  \end{center}%
    \vskip 1.5em%
    {\normalsize
      \lineskip .5em%
      \begin{minipage}[b]{\textwidth}
        \@author
      \end{minipage}\par}%
    \vskip 1em%
    %{\large \@date}%
  \par
  \vskip 1em}
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


\newcommand{\runningheads}{\markboth}
\pagestyle{myheadings}

\normalsize

\setcounter{page}{1}

\endinput

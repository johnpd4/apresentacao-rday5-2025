# Apresentação RDay 5

Código da apresentação e do *shiny* apresentado no Rday 5 em 23/09/2025.

## Apresentação

Para compilar a apresentação é necessário usar *lualatex* e *biber*. Meu VScode usa a receita de *lualatex -> biber -> lualatex* na extensão do *LaTeX Workshop*, além do pacote *LaTeX*. Para que o *LaTeX Workshop* use o *lualatex* como padrão fiz a seguinte mudança no meu *settings.json* do VScode:

```json
{
        "latex-workshop.latex.recipes": [
        {
            "name": "lualatex->biber->lualatex",
            "tools": [
                "lualatex",
                "biber",
                "lualatex"
            ]
        }
    ],
    "latex-workshop.latex.tools": [
        {
            "name": "lualatex",
            "command": "lualatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "-pdf",
                "%DOC%"
            ]
        },
        {
            "name": "biber",
            "command": "biber",
            "args": [
                "%DOCFILE%"
            ]
        }
    ]
}
```

## *shiny*

O código do *shiny* tem várias redundâncias e comentários que eu acabei não retirando antes de colocá-lo aqui. Para o código funcionar é necessário ter todos os pacotes de ambos os arquivos de *ui* e *server*, isso pode ser facilmente feito instalando o pacote *pacman* e manualmente rodando os dois comandos *p_load* de seus arquivos respectivos, *ui* e *server*.

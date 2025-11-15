%%
[0-9]+  {printf("NUMBER: %s\n", yytext);}
[a-zA-Z]+  {printf("Word: %s\n", yytext);}
.   {/* ignore others*/}
%%
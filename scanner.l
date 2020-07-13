%option noyywrap
%x STRING
%x ML_COMMENT
%x ML_COMMENT_2
%{
#include<iostream>
#include<cstdio>
#include<cstdlib>
#include<string>
#include<fstream>
#include"SymbolTable.h"
#include"y.tab.h"
using namespace std;

extern YYSTYPE yylval;
extern SymbolTable table;
void yyerror(char *);


int line_count =1;
int temp_count=0;
int error_count =0;
extern ofstream error;
//ifstream fin("input.txt");
//ofstream tokenout("1505035_token.txt");
extern ofstream logout;
//Sofstream fout2("output.txt");


string token="";
string lexem="";
string str="";
string temp = "";
string backslash="";
int flag  =0 ;
int flag_2 = 0;

%}

WHITESPACE 	[ \t\f\r\v]+
NEWLINE 	\n
BACKSLASH	\\
DIGIT   	[0-9]
DIGITS  	{DIGIT}+
LETTER  	[a-z_A-Z] 
CHAR 		[ -\[]{+}[\]-~]{-}[']
CHARS		[ -~][ -~]+
ID      	{LETTER}({LETTER}|{DIGIT})*		 
FLOAT		{DIGITS}?(\.{DIGITS})?(E[+-]?{DIGITS})?

TOO_DEC_POINT	{FLOAT}+
ILL_NUM		{DIGITS}(E[+-]?{FLOAT})
INV_SUFF_CONST	{DIGITS}{ID}

CHARACTER 	'({CHAR})'
SPECIAL_CHAR 	'\\[tvar"afb0n\\]'
MULTI_CHAR	'({CHARS})'
UNFIN_CHAR 	'({CHAR})|'|'\\' 

%%

{NEWLINE} line_count++;
{WHITESPACE} 		{}

<INITIAL>"/*"	{BEGIN ML_COMMENT; str=yytext;temp_count = line_count;}

<ML_COMMENT>. { str+=yytext;}

<ML_COMMENT>\n	{
			str+=yytext;
			line_count++;  
		}

<ML_COMMENT>"*/" {
			str+= yytext;
			//logout<<"Line no."<< temp_count<<": TOKEN <COMMENT> Lexeme "<<str <<" found\n\n";
			BEGIN INITIAL;
			
		}

<ML_COMMENT><<EOF>> {
			error_count++;
			error<<"Error at line no. "<<temp_count<<": Unterminated comment "<<str;
			BEGIN INITIAL;
		}

<INITIAL>"//"	{BEGIN ML_COMMENT_2; str=yytext; temp_count=0;}

<ML_COMMENT_2>[^\\\r\n] {str+=yytext; flag_2=0;}

<ML_COMMENT_2>\\	{flag_2=1; str+=yytext;}

<ML_COMMENT_2>\n {
		   if(temp_count==1){
		        temp_count =0;
			//logout<<"Line no. "<<line_count<<" TOKEN <COMMENT> lexem "<<str<<" found\n\n";
			line_count+=2;
			BEGIN INITIAL;
		
		   }
		   else if(flag_2==1){
			str+=yytext;
			temp_count++;

		   }
                   else{
			//logout<<"Line no. "<<line_count<<" TOKEN <COMMENT> lexem "<<str<<" found\n\n";
			line_count++;
			BEGIN INITIAL;

		   }

		}

"if"		{
			//tokenout<<"<IF> ";
			//logout<<"Line no."<< line_count<<": TOKEN <IF> Lexeme "<<yytext <<" found\n\n";
			return IF;
		}
		
"else"		{
			//tokenout<<"<ELSE> ";
			//logout<<"Line no."<< line_count<<": TOKEN <ELSE> Lexeme "<<yytext <<" found\n\n";
			return ELSE;
		}

"for"		{
			//tokenout<<"<FOR> ";
			//logout<<"Line no."<< line_count<<": TOKEN <FOR> Lexeme "<<yytext <<" found\n\n";
			return FOR;
		}

"while"		{
			//tokenout<<"<WHILE> ";
			//logout<<"Line no."<< line_count<<": TOKEN <WHILE> Lexeme "<<yytext <<" found\n\n";
			return WHILE;
		}

"do"		{
			//tokenout<<"<DO> ";
			//logout<<"Line no."<< line_count<<": TOKEN <DO> Lexeme "<<yytext <<" found\n\n";
			return DO;
		}

"break"		{
			//tokenout<<"<BREAK> ";
			//logout<<"Line no."<< line_count<<": TOKEN <BREAK> Lexeme "<<yytext <<" found\n\n";
			return BREAK;
		}

"int"		{
			//tokenout<<"<INT> ";
			//logout<<"Line no."<< line_count<<": TOKEN <INT> Lexeme "<<yytext <<" found\n\n";
			return INT;
		}

"char"		{
			//tokenout<<"<CHAR> ";
			//logout<<"Line no."<< line_count<<": TOKEN <CHAR> Lexeme "<<yytext <<" found\n\n";
			return CHAR;
		}

"float"		{
			//tokenout<<"<FLOAT> ";
			//logout<<"Line no."<< line_count<<": TOKEN <FLOAT> Lexeme "<<yytext <<" found\n\n";
			return FLOAT;
		}

"double"	{
			//tokenout<<"<DOUBLE> ";
			//logout<<"Line no."<< line_count<<": TOKEN <DOUBLE> Lexeme "<<yytext <<" found\n\n";
			return DOUBLE;
		}

"void"		{
			//tokenout<<"<VOID> ";
			//logout<<"Line no."<< line_count<<": TOKEN <VOID> Lexeme "<<yytext <<" found\n\n";
			return VOID;
		}

"return"	{
			//tokenout<<"<RETURN> ";
			//logout<<"Line no."<< line_count<<": TOKEN <RETURN> Lexeme "<<yytext <<" found\n\n";
			return RETURN ;
		}

"switch"	{
			//tokenout<<"<SWITCH> ";
			//logout<<"Line no."<< line_count<<": TOKEN <SWITCH> Lexeme "<<yytext <<" found\n\n";
			return SWITCH;
		}

"case"		{
			//tokenout<<"<CASE> ";
			//logout<<"Line no."<< line_count<<": TOKEN <CASE> Lexeme "<<yytext <<" found\n\n";
			return CASE;
		}

"default"	{
			//tokenout<<"<DEFAULT> ";
			//logout<<"Line no."<< line_count<<": TOKEN <DEFAULT> Lexeme "<<yytext <<" found\n\n";
			return DEFAULT;
		}

"continue"	{
			//tokenout<<"<CONTINUE> ";
			//logout<<"Line no."<< line_count<<": TOKEN <CONTINUE> Lexeme "<<yytext <<" found\n\n";
			return CONTINUE;
		}


{DIGITS}	{
			//tokenout<<"<CONST_INT, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <CONST_INT> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_INT",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_INT");
			yylval.SymVal= s;
			return CONST_INT;
		}

{FLOAT}		{
			//tokenout<<"<CONST_FLOAT, "<<yytext<<"> ";
			logout<<"Line no."<< line_count<<": TOKEN <CONST_FLOAT> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_FLOAT",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_FLOAT");
			yylval.SymVal= s;
			return CONST_FLOAT;
		}

{CHARACTER}	{
			
			//tokenout<<"<CONST_CHAR, "<<yytext[1]<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;	
		}

'\\n'		{
			//tokenout<<"<CONST_CHAR, "<<'\n'<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;
		}

'\\t'		{
			//tokenout<<"<CONST_CHAR, "<<'\t'<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;
		}

'\\\\'		{
			//tokenout<<"<CONST_CHAR, "<<'\\'<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;
		}

'\\\"'		{
			//tokenout<<"<CONST_CHAR, "<<'\"'<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;
		}

'\\a'		{
			//tokenout<<"<CONST_CHAR, "<<'\"'<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;
		}

'\\f'		{
			//tokenout<<"<CONST_CHAR, "<<'\"'<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;
		}

'\\r'		{
			//tokenout<<"<CONST_CHAR, "<<'\"'<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;
		}

'\\b'		{
			//tokenout<<"<CONST_CHAR, "<<'\"'<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;
		}

'\\v'		{
			//tokenout<<"<CONST_CHAR, "<<'\"'<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;
		}

'\\0'		{
			//tokenout<<"<CONST_CHAR, "<<'\"'<<"> ";
			//logout<<"Line No."<<line_count<<":  TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
			//bool check = table.Insert(yytext,"CONST_CHAR",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval.SymVal= s;
			return CONST_CHAR;
		}


"+"|"-"		{
			//tokenout<<"<ADDOP, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <ADDOP> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"ADDOP",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext,"ADDOP");
			yylval.SymVal= s;
			return ADDOP;
		}

"*"|"/"|"%"	{
			//tokenout<<"<MULOP, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <MULOP> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"MULOP",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "MULOP");
			yylval.SymVal= s;
			return MULOP;
		}

"++"		{
			//tokenout<<"<INCOP, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <INCOP> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"INCOP",logout);
			//if(check) table.PrintAllScope(logout);
			
			return INCOP;
		}
		
"--"		{
			//tokenout<<"<INCOP, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <INCOP> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"INCOP",logout);
			//if(check) table.PrintAllScope(logout);
			
			return DECOP;
		}

"<"|"<="|">"|">="|"=="|"!=" {
		
			//tokenout<<"<RELOP, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <RELOP> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"RELOP",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "RELOP");
			yylval.SymVal= s;
			return RELOP;
		}

"="		{
			//tokenout<<"<ASSIGNOP, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <ASSIGNOP> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"ASSIGNOP",logout);
			//if(check) table.PrintAllScope(logout);
			
			return ASSIGNOP;
		}

"&&"|"||"	{
			//tokenout<<"<LOGICOP, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <LOGICOP> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"LOGICOP",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "LOGICOP");
			yylval.SymVal= s;
			return LOGICOP;
		}

"&"|"|"|"<<"|">>"    {
		
			//tokenout<<"<BITOP, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <BITOP> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"BITOP",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "BITOP");
			yylval.SymVal= s;
			return BITOP;
		}

"!"		{
			//tokenout<<"<NOT, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <NOT> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"NOT",logout);
			//if(check) table.PrintAllScope(logout);
			return NOT;
		}

"("		{
			//tokenout<<"<LPAREN, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <LPAREN> Lexeme "<<yytext <<" found\n\n";
			return LPAREN;
			
		}

")"		{
			return RPAREN;
			
		}

"{"		{
			//tokenout<<"<LCURL, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <LCURL> Lexeme "<<yytext <<" found\n\n";
			return LCURL;
			
		}

"}"		{
			return RCURL;
			
		}

"["		{
			//tokenout<<"<LTHIRD, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <LTHIRD> Lexeme "<<yytext <<" found\n\n";
			return LTHIRD;
		}

"]"		{
			//tokenout<<"<RTHIRD, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <RTHIRD> Lexeme "<<yytext <<" found\n\n";
			return RTHIRD;
		}

","		{
			//tokenout<<"<COMMA, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <COMMA> Lexeme "<<yytext <<" found\n\n";
			return COMMA;
		}

";"		{
			//tokenout<<"<SEMICOLON, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <SEMICOLON> Lexeme "<<yytext <<" found\n\n";
			return SEMICOLON;
		}

{ID}		{
			//tokenout<<"<ID, "<<yytext<<"> ";
			//logout<<"Line no."<< line_count<<": TOKEN <ID> Lexeme "<<yytext <<" found\n\n";
			//bool check = table.Insert(yytext,"ID",logout);
			//if(check) table.PrintAllScope(logout);
			SymbolInfo* s =new  SymbolInfo(yytext, "ID");
			yylval.SymVal= s;
			return ID;
			
		}

<INITIAL>\"	{BEGIN STRING; lexem =yytext;str = yytext; temp_count = line_count;flag=0;}


<STRING>[^\\\r\nntafrbv0\"]	{lexem = lexem + yytext; 
			str += yytext; flag = 0;
		}

<STRING>\\	{
			if(flag == 1){
				lexem+="\\"; flag =0;
			} 
			else {
				flag =1; 
			}
			str+=yytext;
		
		}

<STRING>\"	{
			if(flag == 1){
				lexem+="\""; flag =0;str += yytext;
			} 
			else{
				str += yytext;
				lexem+= yytext;
				//tokenout<<"<STRING, "<<lexem<<"> ";
				//logout<<"Line no."<< temp_count<<": TOKEN <STRING> Lexeme "<<str <<" found\n\n";
				flag = 0 ;
				BEGIN INITIAL;

			}
		}

<STRING>\n	{
		   if(flag == 0){
			error_count++;
			error<<"Error at Line no."<< temp_count<<": Unterminated String "<<str<<"\n\n";
			str ="";
			lexem = "";
			line_count++;
			BEGIN INITIAL;
			
		    }
		    else{
			str += yytext;
			//lexem = lexem + yytext; 
			line_count++;
		    }

			flag =  0;
		}

<STRING>n	{
			if(flag==1){
				 lexem+="\n"; 
			}
			else lexem+=yytext;
			str+= yytext; 
			flag = 0;
		}

<STRING>t	{
			if(flag==1){
				lexem+="\t"; 
			}
			else lexem+=yytext;
			str+= yytext; 
			flag = 0;
		}

<STRING>a	{
			if(flag==1){
				lexem+="\a"; 
			}
			else lexem+=yytext;
			str+= yytext;
			flag = 0;
		}

<STRING>f	{
			if(flag==1){
				lexem+="\f"; 
			}
			else lexem+=yytext;
			str+= yytext; 
			flag = 0;
		}

<STRING>r	{
			if(flag==1){
				lexem+="\r"; 
			}
			else lexem+=yytext;
			str+= yytext; 
			flag = 0;
		}

<STRING>b	{
			if(flag==1){
				lexem+="\b"; 
			}
			else lexem+=yytext;
			str+= yytext;
			flag = 0;
		}

<STRING>v	{
			if(flag==1){
				lexem+="\v"; 
			}
			else lexem+=yytext;
			str+= yytext;
			flag = 0;
		}

<STRING>0	{
			if(flag==1){
				lexem+="\n"; 
			}
			else lexem+=yytext;
			str+= yytext;
			flag = 0;
		}

{TOO_DEC_POINT}	{
			error_count++;
			error<<"Error at line no. "<<line_count<<": too many decimal point "<<yytext<<"\n\n";
		}
{INV_SUFF_CONST} {
			error_count++;
			error<<"Error at line no. "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<< yytext<<" \n\n";
		}

{ILL_NUM}	{
			error_count++;
			error<<"Error at line no. "<<line_count<<": Ill formed number "<<yytext<<"\n\n";
		}

{MULTI_CHAR}	{
			error_count++;
			error<<"Error at line no. "<<line_count<<": Multi character constant error "<<yytext<<"\n\n";
		}

{UNFIN_CHAR}	{
			error_count++;
			error<<"Error at line no. "<<line_count<<": Unterminated character "<<yytext<<"\n\n";
		}

''		{
			error_count++;
			error<<"Error at line no. "<<line_count<<": Empty character constant error "<<yytext<<"\n\n";
		}

\.		{
			error_count++;
			error<<"Error at line no. "<<line_count<<": Unrecognize character "<<yytext<<"\n\n";
		}
		

%%


/*int main(int argc,char *argv[]){

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
        if(!tokenout){
		cout<<"can't open output file"<<endl;
		return 0;
	}
	if(!logout){
		cout<<"can't open output file"<<endl;
		return 0;
	}
	yyin = fin;
	yylex();
	table.PrintAllScope(logout);
	logout <<endl;
	logout<<"Total line "<<--line_count<<endl;
	logout<<"Total error: "<<error_count<<endl;
	return 0;
}
*/

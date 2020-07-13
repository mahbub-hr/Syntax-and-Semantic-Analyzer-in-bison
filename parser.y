%{
#include<iostream>
#include<cstdlib>
#include<vector>
#include<cstring>
#include<string>
#include<cmath>
#include<fstream>
#include "SymbolTable.h"
//#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern char* yytext;
extern FILE *yyin;
extern int line_count;
extern int error_count;


string list = "";
string specifier = "";
string func  = "";
vector<SymbolInfo*> param_list;
vector<SymbolInfo*> arg_list;
SymbolTable table(50);

ofstream logout("1505035_log.txt"), error("1505035_error.txt");

void yyerror(const char *s)
{
	fprintf(stderr,"line %d : %s\n",line_count,s);
	//error<<"line "<<line_count<<" : "<< s;	
	return;
}

string getOrder(int i){
	if(i == 1) return "1st";
	else if(i == 2) return "2nd";
	else if(i == 3) return "2rd";
	else return "th";
}

%}

%union
{
	SymbolInfo* SymVal; 
}

%start start

%token IF ELSE FOR WHILE  INT FLOAT CHAR DOUBLE VOID RETURN DECOP ASSIGNOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD SEMICOLON COMMA NOT PRINTLN
%token DO COMMENT STRING SWITCH CASE DEFAULT BREAK CONTINUE
%token <SymVal> CONST_INT
%token <SymVal> CONST_FLOAT
%token <SymVal> CONST_CHAR
%token <SymVal> ID

%left <SymVal> LOGICOP
%left <SymVal> RELOP
%left <Symval> BITOP
%left <SymVal> ADDOP
%left <SymVal> MULOP
%left <SymVal> INCOP


%type <SymVal> type_specifier expression logic_expression rel_expression simple_expression term unary_expression factor variable var_declaration 
%type <SymVal> declaration_list program unit func_declaration func_definition parameter_list compound_statement statements statement
%type <SymVal> expression_statement argument_list arguments
 

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%error-verbose


%%

start : program
	{
		//write your code in this block in all the similar blocks below
		//logout << "At line no: " << line_count<<" start : program \n\n";
	}
	;

program : program unit 

	{
		logout << "At line no: " << line_count<< " program : program unit\n\n";
		logout << $1->getName()<<endl<<$2->getName()<<endl<< endl<<endl;
		
		$$->setName($1->getName()+"\n"+$2->getName());
		
	}

	| unit

	{
		logout<< "At line no: " << line_count<<" program : unit\n\n";
		logout << $1->getName()<<endl<< endl<<endl;
		
		$$->setName($1->getName());
	}
	;
	
unit : var_declaration

	{
		logout << "At line no: " << line_count<< " unit : var_declaration\n\n";
		logout << $1->getName()<<endl<< endl<<endl;
		
		$$->setName($1->getName());
	}

     | func_declaration

	{
		logout << "At line no: " << line_count<< " unit : func_declaration\n\n";
		logout << $1->getName()<<endl<< endl<<endl;
	}

     | func_definition

	{
		logout << "At line no: " << line_count<< " unit : func_definition\n\n";
		logout << $1->getName()<<endl<< endl;
	}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON

		{
			logout << "At line no: " << line_count<< " func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n";
			logout <<$1->getName()<<" "<< $2->getName()<<"( "<<$4->getName()<<" );\n\n\n";
			
			SymbolInfo *temp = new SymbolInfo($2->getName(),"ID");
			temp->setDataType($1->getName());
			temp->setIdType("FUNC");
			temp->setParam(param_list);
			temp->isDeclared = true;
			param_list.clear();
			
			SymbolInfo* test = table.Insert(temp);
			if( test != 0 ) 
				{	
					if(test->isDefined == false){
						error << "Error at line "<<line_count<<" : Multiple declaration of "<<$2->getName()<<"\n\n";
						error_count++;
					}
				}
				
			$$ = new SymbolInfo ($1->getName()+" "+ $2->getName()+"("+$4->getName()+");");
			
		}

		| type_specifier ID LPAREN RPAREN SEMICOLON

		{
			logout << "At line no: " << line_count<< " func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n";
			
			logout <<$1->getName()<<" "<< $2->getName()<<"();\n\n\n";
			
			SymbolInfo *temp = new SymbolInfo($2->getName(),$2->getType());
			temp->setDataType($1->getName());
			temp->setIdType("FUNC");
			temp->setParam(param_list);
			temp->isDeclared = true;
			param_list.clear();
			SymbolInfo *test = table.Insert(temp);
			if( test != 0 ) 
				{	
					if(test->isDefined == false){
						error << "Error at line "<<line_count<<" : Multiple declaration of "<<$2->getName()<<"\n\n";
						error_count++;
					}
				}
				
			$$ = new SymbolInfo ($1->getName()+" "+ $2->getName()+"();");
		}
		
		| error ID LPAREN parameter_list RPAREN SEMICOLON
		{
			yyclearin; error_count++;
			logout << "At line "<<line_count <<" error ID LPAREN parameter_list RPAREN SEMICOLON\n\n";
			logout << "error"<<$2->getName()<<"("+ $4->getName()+");\n\n";
			error << "Error at line "<< line_count<< " : expecting return type of fucntion "<<$2->getName()<<"\n\n";
			
			SymbolInfo *temp = new SymbolInfo($2->getName(),"ID");
			temp->setDataType($2->getName());
			temp->setIdType("FUNC");
			temp->setParam(param_list);
			temp->isDeclared = true;
			param_list.clear();
			SymbolInfo* test = table.Insert(temp);
			if( test != 0 ) 
				{	
					if(test->isDefined == false){
						error << "Error at line "<<line_count<<" : Multiple declaration of "<<$2->getName()<<"\n\n";
						error_count++;
					}
				}
				
			$$ = new SymbolInfo ("error "+$2->getName()+"("+ $4->getName()+");");
			yyerrok;
		}
		
		| type_specifier ID LPAREN parameter_list RPAREN  error
		{
			yyclearin; error_count++;
			error << "Error at line "<< line_count<< " : expecting ; after function declaration\n\n";
			$$ = new SymbolInfo ($1->getName()+$2->getName()+"("+ $4->getName()+") error");
			yyerrok;
		}
		
		| error ID LPAREN RPAREN SEMICOLON
		{
			yyclearin; error_count++;
			error << "Error at line "<< line_count<< " : expecting return type of fucntion "<<$2->getName()<<"\n\n";
			$$ = new SymbolInfo ("error "+$2->getName()+"();");
			yyerrok;
		}
		
		| type_specifier ID LPAREN RPAREN  error
		{
			yyclearin; error_count++;
			error << "Error at line "<< line_count<< " : expecting ; after function declaration\n\n";
			$$ = new SymbolInfo ($1->getName()+" "+ $2->getName()+"() error");
			yyerrok;
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN { 

			SymbolInfo *temp = new SymbolInfo($2->getName(),"ID");
			temp->setDataType($1->getName());
			temp->setIdType("FUNC");
			
			temp->isDefined = true;
			
			SymbolInfo* test = table.Insert(temp);
			
			if( test != 0 ) 
				{	
				//cout <<specifier<<endl;
					if(test->getDataType() != $1->getName())
					    error<< "Error at line :"<<line_count << " : return type mismacth\n\n";	
					if(test->isDefined == true){
						error << "Error at line "<<line_count<<" : Redefinition of function "<<$2->getName()<<"\n\n";
						error_count++;
					}
					else {
						test->isDefined = true;
						const vector<SymbolInfo*>* param = test->getParam();
				//cout << param_list.size()<<endl;
						if(param_list.size() != (*param).size()){
							error <<"Error at line "<<line_count<<" : Parameter number does not match with previous fucntion declaration\n\n ";
						}
						else{
							for(int i=0; i<param_list.size();i++ ){
								if(param_list[i]->getDataType() != (*param)[i]->getDataType()){
									error <<"Error at line "<<line_count<<" : parameter type does not match with previous function declaration\n\n";
								}
					
							}
						}
					//cout <<test->getName()<<endl;
					}
				}
				
			else{

				temp->setParam(param_list);	
			
			}
			
			func = $1->getName();
			//param_list.clear();	
			} compound_statement 

		{
			logout << "At line no: " << line_count<< " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n";
			logout <<$1->getName()<<" "<< $2->getName()<<"("<<$4->getName()<<")"<<$7->getName()<<"\n\n\n";
			
			$$->setName($1->getName()+" "+ $2->getName()+"("+$4->getName()+")"+$7->getName());
		}

		| type_specifier ID LPAREN RPAREN { 
		
			SymbolInfo *temp = new SymbolInfo($2->getName(),"ID");
			temp->setDataType($1->getName());
			temp->setIdType("FUNC");
			
			SymbolInfo* test = table.Insert(temp);
			if( test != 0 ) 
				{
					if(test->getDataType() != $1->getName())
					    error<< "Error at line :"<<line_count << " : return type mismacth\n\n";	
					if(test->isDefined == true){
						error << "Error at line "<<line_count<<" : Redefinition of function "<<$2->getName()<<"\n\n";
						error_count++;
					}
					else {
						test->isDefined = true;
					}
				}
				
			else{
				temp->setParam(param_list);
			}
			
			func = $2->getName();
			param_list.clear();
		 } compound_statement

		{
			logout << "At line no: " << line_count<< " func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n";
			logout <<$1->getName()<<" "<<$2->getName()<<"()"<<$6->getName()<<"\n\n\n";
			
			$$->setName($1->getName()+" "+ $2->getName()+"()"+$6->getName());
		}

 		;				


parameter_list  : parameter_list COMMA type_specifier ID

		{
			logout << "At line no: " << line_count<< " parameter_list  : parameter_list COMMA type_specifier ID\n\n";
			logout << $1->getName()<<","<<$3->getName()<<"  "<<$4->getName()<<endl<<endl<<endl;
			
			SymbolInfo* temp = new SymbolInfo($4->getName(), "ID");
			temp->setDataType(specifier);
			param_list.push_back(temp);
			
			
			$$->setName($1->getName()+","+$3->getName()+"  "+$4->getName());
			//for(int i=0; i<param_list.size(); i++) cout <<param_list[i].getName()<< " ";
			
			//cout << $3->getName()<<endl;
		}

		| parameter_list COMMA type_specifier

		{
			logout << "At line no: " << line_count<< " parameter_list  : parameter_list COMMA type_specifier\n\n";
			logout << $1->getName()<<","<<$3->getName()<<endl<<endl;
			
			SymbolInfo* temp = new SymbolInfo($3->getName(), $3->getType());
			temp->setDataType(specifier);
			param_list.push_back(temp);
			
			$$->setName($1->getName()+","+$3->getName());
		}

 		| type_specifier ID

		{
			logout << "At line no: " << line_count<< " parameter_list  : type_specifier ID\n\n";
			logout << $1->getName()<<"  "<<$2->getName()<<endl<<endl;
			
			SymbolInfo* temp = new SymbolInfo($2->getName(), $2->getType());
			temp->setDataType(specifier);
			param_list.push_back(temp);
			
			$$->setName($1->getName()+"  "+$2->getName());
			//for(int i=0; i<param_list.size(); i++) cout <<param_list[i]->getName()<< " ";
			//cout <<"helo here "<< $$->getName()<<endl;
			
		}

		| type_specifier

		{
			logout << "At line no: " << line_count<< " parameter_list  : type_specifier\n\n";
			logout << $1->getName()<<endl<<endl;
			
			SymbolInfo* temp = new SymbolInfo($1->getName(), $1->getType());
			temp->setDataType(specifier);
			param_list.push_back(temp);
			
			$$->setName($1->getName());

		}

 		;

 		
compound_statement : LCURL {table.EnterScope(logout);for(int i =0; i<param_list.size(); i++) table.Insert(param_list[i]); cout <<param_list.size();param_list.clear();} statements RCURL 

		{
			logout << "At line no: " << line_count<< " compound_statement : LCURL statements RCURL\n\n";
			logout << "{\n"<<$3->getName()<<"\n}"<<endl<< endl<<endl;
		
			$$ =  new SymbolInfo("{\n"+$3->getName()+"\n}");
			
			table.PrintAllScope(logout);	table.ExitScope(logout);
		}
 		    | LCURL {table.EnterScope(logout);for(int i =0; i<param_list.size(); i++) table.Insert(param_list[i]);param_list.clear();} RCURL

		{
			logout << "At line no: " << line_count<< " compound_statement : LCURL RCURL\n\n";
			logout << "{\n\n\n}"<<endl<< endl;
		
			$$ = new SymbolInfo("{\n\n}");
			table.PrintAllScope(logout);	table.ExitScope(logout);
		}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON

		{
			logout << "At line no: " << line_count<< " var_declaration : type_specifier declaration_list SEMICOLON\n\n";      
			logout <<$1->getName()<<" "<< $2->getName()<<";\n\n\n";
			
			specifier = $1->getName();
			$$->setName($1->getName()+" "+ $2->getName()+";");
		}
		
		| type_specifier declaration_list error
		{
			yyclearin; error_count++;
			error << "Error at line "<< line_count<< " : expecting ; after variable declaration\n\n";
			yyerrok;
		}
		| error declaration_list SEMICOLON
		{
			yyclearin; error_count++;
			error << "Error at line "<< line_count<< " : expecting type specifier before variable declaration\n\n";
			yyerrok;
		}

 		 ;
 		 
type_specifier	: INT

		{
			logout << "At line no: " << line_count<< " type_specifier : INT\n\n"<< "int\n\n";
			$$ = new SymbolInfo("int");
			specifier = "int";
			//cout <<"int"<<endl;
			//logout << $$->getName()<<endl;
		}

 		| FLOAT

		{
			logout << "At line no: " << line_count<< " type_specifier : FLOAT\n\n"<<"float\n\n";
			$$ = new SymbolInfo("float");
			specifier = "float";
		}

 		| VOID

		{
			logout << "At line no: " << line_count<< " type_specifier : VOID\n\n"<<"void\n\n";
			$$ = new SymbolInfo("void");
			specifier = "void";
		}

 		;
 		
declaration_list : declaration_list COMMA ID
		
		{
			logout << "At line no: " << line_count<< " declaration_list : declaration_list COMMA ID\n\n";
			logout << $1->getName()<<","<<$3->getName()<<"\n\n";
			
			if(specifier == "void") 
				{
					error << "Error at line "<<line_count <<" : variable type can not be void\n\n";
					error_count++;
				}
			
			
			SymbolInfo *temp = new SymbolInfo($3->getName(),$3->getType());
			temp->setDataType(specifier);
			temp->setIdType("VAR");
			SymbolInfo* test = table.Insert(temp);
			if( test != 0 ){ 
				error << "Error at line "<<line_count<<" : Multiple declaration of "<<$3->getName()<<"\n\n";
				error_count++;
			}	
			
			$$->setName($1->getName()+","+$3->getName()); 
		}

 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD

		{
			logout << "At line no: " << line_count<< " declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n";
			logout << $1->getName() << " , " << $3->getName()<<"["<<$5->getName()<<"]\n\n";
			
			
			if(specifier == "void") 
				{
					error << "Error at line "<<line_count <<" : array type can not be void\n\n";
					error_count++;
				}
			
			SymbolInfo *temp = new SymbolInfo($3->getName(),$3->getType());
			temp->setDataType(specifier);
			temp->setIdType("ARRAY");
			table.PrintAllScope(logout);
			temp->arraySize = atoi(($5->getName()).c_str());
			SymbolInfo* test = table.Insert(temp);
			if( test != 0 ) {
				error << "Error at line "<<line_count<<" : Multiple declaration of "<<$3->getName()<<"\n\n";
				error_count++;
			}
			list = $1->getName()+","+$3->getName()+"["+$5->getName()+"]";
			$$->setName(list);
		}

 		  | ID

		{
			logout << "At line no: " << line_count<< " declaration_list : ID\n\n"<<$1->getName()<<"\n\n";
			
			if(specifier == "void") 
				{
					error << "Error at line "<<line_count <<" : variable type can not be void\n\n";
					error_count++;
				}
			
			SymbolInfo *temp = new SymbolInfo($1->getName(),$1->getType());
			temp->setDataType(specifier);
			temp->setIdType("VAR");
			SymbolInfo* test = table.Insert(temp);
			if( test != 0 ) {
				error << "Error at line "<<line_count<<" : Multiple declaration of "<<$1->getName()<<"\n\n";
				error_count++;
			}
						
			$$ = new SymbolInfo($1->getName());
			
		}

 		  | ID LTHIRD CONST_INT RTHIRD

		{
			logout << "At line no: " << line_count<< " declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n";
			logout << $1->getName()<<"["<<$3->getName()<<"]\n\n";
			
			if(specifier == "void") 
				{
					error << "Error at line "<<line_count <<" : array type can not be void\n\n";
					error_count++;
				}
			
			SymbolInfo *temp = new SymbolInfo($1->getName(),"ID");
			temp->setDataType(specifier);
			temp->setIdType("ARRAY");
			temp->arraySize = atoi(($3->getName()).c_str());
			//cout <<temp->getIdType()<<endl;
			SymbolInfo* test = table.Insert(temp);
			if( test != 0 ) {
				logout << "Error at line "<<line_count<<" : Multiple declaration of "<<$1->getName()<<"\n\n";
				error << "Error at line "<<line_count<<" : Multiple declaration of "<<$1->getName()<<"\n\n";
				error_count++;
			}
	
			$$ = new SymbolInfo($1->getName()+"["+$3->getName()+"]");			
		}
		
		  | ID LTHIRD error RTHIRD
		  
		{
			yyclearin;	error_count++;
			logout << "At line no: " << line_count<< " declaration_list : ID LTHIRD error RTHIRD\n\n";
			logout << $1->getName()<<"[error]\n\n";
			$1->setDataType(specifier);
			$1->setIdType("ARRAY");
			
			if(specifier == "void") 
				{
					error << "Error at line "<<line_count <<" : array type can not be void\n\n";
					error_count++;
				}
			SymbolInfo *temp = new SymbolInfo($1->getName(),$1->getType());
			temp->setDataType(specifier);
			temp->setIdType("ARRAY");
			
			SymbolInfo* test = table.Insert(temp);
			if( test != 0 ){
				error << "Error at line "<<line_count<<" : Multiple declaration of "<<$1->getName()<<"\n\n";
				error_count++;
			}
			error << "Error at line "<<line_count <<" : Non-integer Array Index\n\n";
			
			$$ = new SymbolInfo($1->getName()+"[error]");
			yyerrok;
		}
		
		  |  declaration_list COMMA ID LTHIRD error RTHIRD
		
		{
			yyclearin;	error_count++;
			logout << "At line no: " << line_count<< " declaration_list : ID LTHIRD error RTHIRD\n\n";
			logout << $3->getName()<<"[error]\n\n";
			
			if(specifier == "void") 
				{
					error << "Error at line "<<line_count <<" : array type can not be void\n\n";
					error_count++;
				}
			SymbolInfo *temp = new SymbolInfo($3->getName(),$3->getType());
			temp->setDataType(specifier);
			temp->setIdType("ARRAY");
			
			SymbolInfo* test = table.Insert(temp);
			if( test != 0 ){
				error << "Error at line "<<line_count<<" : Multiple declaration of "<<$3->getName()<<"\n\n";
				error_count++;
			}
			
			error << "Error at line "<<line_count <<" : Non-integer Array Index\n\n";
			
			$$ = new SymbolInfo($3->getName()+"[error]");
			yyerrok;
		}
 		  ;
 		  
statements : statement

		{
			logout << "At line no: " << line_count<< " statements : statement\n\n";
			logout << $1->getName()<<endl<< endl<<endl;
		
			$$->setName($1->getName());
		}

	   | statements statement

		{
			logout << "At line no: " << line_count<< " statements : statements statement\n\n";
			logout << $1->getName()<<endl<<$2->getName()<<endl<<endl<<endl;
		
			$$->setName($1->getName()+"\n"+$2->getName());
		}
	   ;
	   
statement : var_declaration

		{
			logout << "At line no: " << line_count<< " statement : var_declaration\n\n";
			logout << $1->getName()<<endl<< endl<<endl;
		
			$$ = new SymbolInfo($1->getName());
		}

	  | expression_statement
		{
			logout << "At line no: " << line_count<< " statement : expression_statement\n\n";
			logout << $1->getName() << endl<<endl<<endl;
		
			$$ = new SymbolInfo($1->getName());
		}

	  | compound_statement
		{
			logout << "At line no: " << line_count<< " statement : compound_statement\n\n";
			logout << $1->getName() <<endl<< endl<<endl;
		
			$$ = new SymbolInfo($1->getName());
		}

	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
		{
			logout << "At line no: " << line_count<< " statement : FOR LPAREN expression_statement expression_statement expression RPAREN statementn\n\n";
			logout << "for("<<$3->getName()<<$4->getName()<<$5->getName()<<")"<<$7->getName()<< endl<<endl<<endl;
		
			$$ = new SymbolInfo("for("+$3->getName()+$4->getName()+$5->getName()+")"+$7->getName());
		}

	  | IF LPAREN expression RPAREN statement	%prec LOWER_THAN_ELSE
		{
			logout << "At line no: " << line_count<< " statement : IF LPAREN expression RPAREN statement\n\n";
			logout << "if("<<$3->getName()<<")"<<$5->getName()<< endl<<endl<<endl;
		
			$$ = new SymbolInfo("if("+$3->getName()+")"+$5->getName());
			
		}

	  | IF LPAREN expression RPAREN statement ELSE statement
		{
			logout << "At line no: " << line_count<< " statement : IF LPAREN expression RPAREN statement ELSE statement\n\n";
			logout << "if("<<$3->getName()<<")"<<$5->getName()<<"else"<<$7->getName()<<endl<< endl<<endl;
		
			$$ = new SymbolInfo("if("+$3->getName()+")"+$5->getName()+"else"+$7->getName());
		}

	  | WHILE LPAREN expression RPAREN statement
		{
			logout << "At line no: " << line_count<< " statement : WHILE LPAREN expression RPAREN statement\n\n";
			logout << "while("<<$3->getName()<<")"<<$5->getName()<<endl<< endl<<endl;
		
			$$ = new SymbolInfo("while("+$3->getName()+")"+$5->getName());
			
		}

	  | PRINTLN LPAREN ID RPAREN SEMICOLON
		{
			logout << "At line no: " << line_count<< " statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n";
			logout << "println("<<$3->getName()<<");"<<endl<< endl<<endl;
		
			$$ = new SymbolInfo("println("+$3->getName()+");");
		}

	  | RETURN expression SEMICOLON
		{
			logout << "At line no: " << line_count<< " statement : RETURN expression SEMICOLON\n\n";
			logout <<"return "<< $2->getName() <<";"<<endl<< endl<<endl;
			
			SymbolInfo* test = table.LookUp(func,logout);
			
			if(test != 0){
				string dataType = test->getDataType();
				if((dataType == "void") || ((dataType == "int") && ($2->getDataType() == "float"))) {
					error<< "Error at line "<<line_count<<" : Return type does not match \n\n";
					error_count++;
				}
			
			}
			$$ = new SymbolInfo("return "+ $2->getName()+";");
		}
		
	  | PRINTLN LPAREN ID RPAREN error
		{
			logout << "At line no: " << line_count<< " statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n";
			logout << "println("<<$3->getName()<<") error"<<endl<< endl<<endl;
			
			$$ = new SymbolInfo("println("+$3->getName()+") error"); 
			yyclearin; error_count++;
			error << "Error at line "<< line_count <<" : Expecting a ; after println statement\n\n";
			yyerrok;
		}

	  | RETURN expression error
		{
			logout << "At line no: " << line_count<< " statement : RETURN expression SEMICOLON\n\n";
			logout <<"return "<< $2->getName() <<"error"<<endl<< endl<<endl;
		
			$$ = new SymbolInfo("return "+ $2->getName()+"error");
			yyclearin; error_count++;
			error << "Error at line "<< line_count <<" : Expecting a ; after return statement\n\n";
			yyerrok;
		}
	  ;
	  
expression_statement 	: SEMICOLON
		{
			logout << "At line no: " << line_count<< " expression_statement : SEMICOLON\n\n";
			logout << ";" << endl<<endl;
		
			$$ = new SymbolInfo(";");			
		}
			
			| expression SEMICOLON
 
		{
			logout << "At line no: " << line_count<< " expression_statement : expression SEMICOLON\n\n";
			logout << $1->getName() <<";"<< endl<<endl<<endl;
		
			$$ = new SymbolInfo($1->getName()+";","expression_statement");			
			$$->setDataType($1->getDataType());
			
		}
		
			| expression error
			
		{
			yyclearin; error_count++;
			error << "Error at line "<< line_count <<" : Expecting a ; after expression end\n\n";
			yyerrok;
		}
		
			| error SEMICOLON
			
		{
			yyclearin; error_count++;
			error << "Error at line "<< line_count <<" : not an expression\n\n";
			yyerrok;
		}
			;
	  
variable : ID
		{
			logout << "At line no: " << line_count<< " variable : ID\n\n";
			logout << $1->getName() << endl<<endl;
		
			$$ = new SymbolInfo($1->getName(),"variable");	
			SymbolInfo* temp = table.LookUp($1->getName(),logout);
			
			if(temp == 0){
				error_count++;
				error << "Error at line "<< line_count<< " : undecalared variable : "<<$1->getName()<<endl<<endl;
			}
			else{
				if(temp->getIdType() == "ARRAY") {
					error_count++;
					error<<"Error at line "<<line_count<<" : Trying to access array like normal variable\n\n";
				
				}		
				$$->setDataType(temp->getDataType());
			}
			
		}
 		
	 | ID LTHIRD expression RTHIRD 

		{
			logout << "At line no: " << line_count<< " variable : ID LTHIRD expression RTHIRD\n\n";
			logout << $1->getName()<<"["<<$3->getName()<<"]"<< endl<<endl;
		
			$$ = new SymbolInfo($1->getName()+"["+$3->getName()+"]","variable");	
			SymbolInfo* temp = table.LookUp($1->getName(),logout);
			if(temp == 0){
				error_count++;
				error << "Error at line "<< line_count<< " : undecalared array : "<<$1->getName()<<endl<<endl;
			}
			else{
				if(temp->getIdType() == "VAR") {
					error_count++;
					error<<"Error at line "<<line_count<<" : "<<$1->getName()<<" not an Array\n\n";
				
				}		
				$$->setDataType(temp->getDataType());
			}
			
			if($3->getDataType() == "float") {
				error_count++;
				error << "Error at line "<< line_count<<" : Non-integer array index\n\n";
			}
		}
		
	 ;
	 
expression : logic_expression	
		{
			logout << "At line no: " << line_count<< " expression : logic_expression\n\n";
			logout << $1->getName() << endl<<endl;
		
			$$ = new SymbolInfo($1->getName(),"expression");			
			$$->setDataType($1->getDataType());
		}

	   | variable ASSIGNOP logic_expression 
		{
			logout << "At line no: " << line_count<< " expression : variable ASSIGNOP logic_expression\n\n";
			logout << $1->getName()<<"="<<$3->getName()<< endl<<endl<<endl;
		
			$$ = new SymbolInfo($1->getName()+"="+$3->getName(),"logic_expression");			
			if($1->getDataType() == "float" || $3->getDataType() == "float") $$->setDataType("float");
			else $$->setDataType("int");
			
			if($1->getDataType() == "int" && $3->getDataType() == "float"){
				error_count++;
				error<< "Error at line "<<line_count<<" : Type mismatch \n\n";
				error <<"Warning at line "<<line_count <<" : Possible data loss in float to int conversion\n\n";
				logout<<"Warning at line "<<line_count <<" : Possible data loss in float to int conversion\n\n";
			}
		
		}	
	   ;
			
logic_expression : rel_expression
		{
			logout << "At line no: " << line_count<< " logic_expression : rel_expression\n\n";
			logout << $1->getName() << endl<<endl;
		
			$$ = new SymbolInfo($1->getName(),"logic_expression");			
			$$->setDataType($1->getDataType());
			
		}
	
		 | rel_expression LOGICOP rel_expression 
		{
			logout << "At line no: " << line_count<< " logic_expression : rel_expression LOGICOP rel_expression\n\n";
			logout << $1->getName()<<$2->getName()<<$3->getName()<< endl<<endl;
		
			$$ = new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"logic_expression");			
			$$->setDataType("int");
	
		}	
		 ;
			
rel_expression	: simple_expression 
		{
			logout << "At line no: " << line_count<< " rel_expression : simple_expression\n\n";
			logout << $1->getName() << endl<<endl;
		
			$$ = new SymbolInfo($1->getName(),"rel_expression");			
			$$->setDataType($1->getDataType());

		}

		| simple_expression RELOP simple_expression
		{
			logout << "At line no: " << line_count<< " rel_expression : simple_expression RELOP simple_expression\n\n";
			logout << $1->getName()<<$2->getName()<<$3->getName()<< endl<<endl;
		
			$$ = new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"rel_expression");			
			$$->setDataType("int");
			
		}	
		;
				
simple_expression : term 
		{
			logout << "At line no: " << line_count<< " simple_expression : term\n\n";
			logout << $1->getName() << endl<<endl;
		
			$$ = new SymbolInfo($1->getName(),"simple_expression");			
			$$->setDataType($1->getDataType());

		}

		  | simple_expression ADDOP term
		{
			logout << "At line no: " << line_count<< " simple_expression : simple_expression ADDOP term\n\n";
			logout << $1->getName()<<$2->getName()<<$3->getName()<< endl<<endl;
		
			$$ = new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"simple_expression");			
			if($1->getDataType() == "float" || $3->getDataType() == "float") $$->setDataType("float");
			else $$->setDataType("int");	
		} 
		  ;
					
term :	unary_expression
		{
			logout << "At line no: " << line_count<< " term : unary_expression\n\n";
			logout << $1->getName() << endl<<endl;
		
			$$ = new SymbolInfo($1->getName(),"term");			
			$$->setDataType($1->getDataType());
		}

     |  term MULOP unary_expression
		{
			logout << "At line no: " << line_count<< " term : term MULOP unary_expression\n\n";
			logout << $1->getName()<<$2->getName()<<$3->getName()<< endl<<endl;
		
			$$ = new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"term");			
			if($1->getDataType() == "float" || $3->getDataType() == "float"){
				$$->setDataType("float");
				if($2->getName() == "%") error<<"Error at line "<< line_count <<" : both operands on modulus should be integer\n\n";
			}
			else $$->setDataType("int");
		}
     ;

unary_expression : ADDOP unary_expression
		{
			logout << "At line no: " << line_count<< " unary_expression : ADDOP unary_expression\n\n";
			logout << $1->getName()<<$2->getName()<< endl<<endl;
		
			$$ = new SymbolInfo($1->getName()+$2->getName(),"unary_expression");			
			$$->setDataType($2->getDataType());
		}
  
		 | NOT unary_expression
		{
			logout << "At line no: " << line_count<< " unary_expression : NOT unary_expression\n\n";
			logout << "!"<<$2->getName()<< endl<<endl;
		
			$$ = new SymbolInfo("!"+$2->getName(),"unary_expression");			
			$$->setDataType($2->getDataType());
		}
 
		 | factor 
		{
			logout << "At line no: " << line_count<< " unary_expression : factor\n\n";
			logout << $1->getName() << endl<<endl;
		
			$$ = new SymbolInfo($1->getName(),"unary_expression");			
			$$->setDataType($1->getDataType());
		}
		 ;
	
factor	: variable 
		{
			logout << "At line no: " << line_count<< " factor : variable\n\n";
			logout << $1->getName() << endl<<endl;
		
			$$ = new SymbolInfo($1->getName(),"factor");			
			$$->setDataType($1->getDataType());

		}

	| ID LPAREN argument_list RPAREN
		{
			logout << "At line no: " << line_count<< " factor : ID LPAREN argument_list RPAREN\n\n";
			logout <<$1->getName()<<"("<< $3->getName()<<")\n\n";
			
			$$ = new SymbolInfo($1->getName()+"("+$3->getName()+")");
			SymbolInfo* temp = table.LookUp($1->getName(),logout);
			
			if(temp == 0){
				error_count++;
				error << "Error at line "<< line_count<< " : function "<<$1->getName()<<" does not exist\n\n";
			}
			else{
			
			if(temp->getIdType() != "FUNC") {
				error_count++;
			 	error << "Error at line "<< line_count<< " : function "<<$1->getName()<<" does not exist\n\n";
			}
			else{
				if(temp->getDataType() == "void") {
					error_count++;
					error<<"Error at line "<<line_count<<" : a void function can not be called as a part of an expression or assignment\n\n";
				}
				if(temp->isDefined == false){
					error << "Error at line "<< line_count<<" : function "<<$1->getName()<<" is not defined\n\n";
				}
				const vector<SymbolInfo*>* param = temp->getParam();
				
				if(arg_list.size() != (*param).size()){
				error_count++;
					error <<"Error at line "<<line_count<<" : Parameter number does not match\n\n ";
				}
				else{
					for(int i=0; i<arg_list.size();i++ ){
						if(arg_list[i]->getDataType() != (*param)[i]->getDataType()){
							error <<"Error at line "<<line_count<<" : parameter type does not match\n\n";
							error_count++;
						}
					
					}
				}		
				$$->setDataType(temp->getDataType());
			}
			}
			arg_list.clear();
		}

	| LPAREN expression RPAREN
		{
			logout << "At line no: " << line_count<< " factor : LPAREN expression RPAREN\n\n";
			logout <<"("<< $2->getName()<<")\n\n";
			
			$$ = new SymbolInfo("("+$2->getName()+")","factor");
			$$->setDataType($2->getDataType());
			
		}

	| CONST_INT 
		{
			logout << "At line no: " << line_count<< " factor : CONST_INT\n\n";
			logout << $1->getName() << endl<<endl;

			$$ = new SymbolInfo($1->getName(),"CONST_INT");			
			$$->setDataType("int");
			
		}

	| CONST_FLOAT
		{
			logout << "At line no: " << line_count<< " factor : CONST_FLOAT\n\n";
			logout << $1->getName() << endl<<endl;
		
			$$ = new SymbolInfo($1->getName(),"CONST_FLOAT");			
			$$->setDataType("float");
		}

	| variable INCOP 
		{
			logout << "At line no: " << line_count<< " factor : variable INCOP\n\n";
			logout << $1->getName()<<"++" << endl<<endl;
		
			$$ = new SymbolInfo($1->getName()+"++");
			$$->setDataType($1->getDataType());
		}

	| variable DECOP
		{
			logout << "At line no: " << line_count<< " factor : vaiable DECOP\n\n";
			logout << $1->getName()<<"--" << endl<<endl;
		
			$$ = new SymbolInfo($1->getName()+"--");
			$$->setDataType($1->getDataType());
		}
	;
	
argument_list : arguments
		{
			logout << "At line no: " << line_count<< " argument_list : arguments\n\n";
			logout << $1->getName() << endl<<endl;
		
			$$ = new SymbolInfo($1->getName());
			$$->setDataType($1->getDataType());
		}

	      |
		{
			logout << "At line no: " << line_count<< " argument_list : \n\n";
			logout << endl<<endl;
		
			$$ = new SymbolInfo("","arguments");
			//cout<<"hello \n";
		}
	      ;
	
arguments : arguments COMMA logic_expression
		{
			logout << "At line no: " << line_count<< " arguments : arguments COMMA logic_expression\n\n";
			logout << $1->getName()<<","<<$3->getName() << endl<<endl;
		
			SymbolInfo* temp = new SymbolInfo($3->getName(), "arguments");
			temp->setDataType($3->getDataType());
			arg_list.push_back(temp);
			
			$$ = new SymbolInfo($1->getName()+","+$3->getName(),"arguments");
			
		}

	      | logic_expression
		{
			logout << "At line no: " << line_count<< " arguments : logic_expression\n\n";
			logout << $1->getName() << endl<<endl;
			
			SymbolInfo* temp = new SymbolInfo($1->getName(), "logic_expression");
			temp->setDataType($1->getDataType());
			arg_list.push_back(temp);
			
			$$ = new SymbolInfo($1->getName(),"arguments");
			$$->setDataType($1->getDataType());
		}

	      ;
 

%%

int main(int argc,char *argv[])
{

	if((yyin = fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	yyparse();
	
	logout<<endl<<endl<<"		Symbol Table:"<<endl<<endl;
	table.PrintAllScope(logout);
	logout <<endl<<endl;
	logout << "Total lines : "<< --line_count<< endl<<endl << "Total errors : "<<error_count << endl; 
	error  <<"Total errors : "<<error_count<< endl;
	return 0;
}


# Simple Expression Evaluator

 Simple Expression Evaluator is a simple Math parser supporting the most basic oprerators: +, -, *, /, \ [^1] and Parentheses   
 
 Simply pase an expression to the parser, and it will return the result to you, and if anything goes wrong. You'll get an error type  (None, Parentheses, Wrong Char, Divide By Zero) and a pointer (PChar) to where in the expression the error where detected.

![image](https://github.com/JensBorrisholt/Simple-Expression-Evaluator/blob/main/Demo.png)

It's easy to use: 

```Delphi
// This project uses Delphi Console https://github.com/JensBorrisholt/DelphiConsole

uses
  System.SysUtils,
  System.Console in 'System.Console.pas',
  SimpleExpressionEvaluator in '..\SimpleExpressionEvaluator.pas';

begin
  while True do
  begin
    Console.ForegroundColor := TConsoleColor.White;
    Console.Write('Enter an expression (or an empty string to exit): ');

    var Input := Console.ReadLine.Replace(sLineBreak, '');
    if Input = '' then
      Break;

    var eval: TExprEval;
    var  result := eval.Evaluate(Input);
    Console.CursorLeft := 5;
    if eval.EvaluationError <> TEvaluationError.None then
    begin
      Console.ForegroundColor := TConsoleColor.Red;
      Console.Write('Error parsing "%s". Error %s at "%s"', [Input, eval.ErrorType, eval.ErrPos]);
    end
    else
    begin
      Console.ForegroundColor := TConsoleColor.Green;
      Console.Write('"%s" = %s', [Input, FormatFloat('#.##', result)]);
    end;

    Console.WriteLine;
    Console.WriteLine;
  end;

end.
```
In this Repo you'll also find a DUintX test project, with 40 tests, testing the parser.   

![image](https://user-images.githubusercontent.com/8626074/153999821-6838058e-f083-4695-a026-17a0c2f9f358.png)

In the test project you'll also see an example of ho to write your own CustomTestCaseAttribute: 

```Delphi
type
  ExpesionTestAttribute = class(CustomTestCaseAttribute)
  protected
    FCaseInfo: TestCaseInfo;
    function GetCaseInfo: TestCaseInfo; override;
    function GetName: string;
    function GetValues: TValueArray;
  public
    constructor Create(const aExpresstion: string; const aExpectedResult: Double; aEvaluationError: TEvaluationError = None; aErrorPos: string = ''); overload;
  end;
```

And how to use it:

```Delphi
  [TestFixture]
  Tests = class
  ...
  public
    [Test]
    [ExpesionTest('1234', 1234)]
    [ExpesionTest('1+2*3', 7)]
    procedure SimpleExpressions(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
...
```

[^1]: \ is the oprerator for div. Div is division in which the fractional part (remainder) is discarded.

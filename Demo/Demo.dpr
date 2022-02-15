program Demo;

{$APPTYPE CONSOLE}

{$R *.res}

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

unit SimpleExpressionEvaluator;

interface

uses
  Sysutils;

Type
  TEvaluationError = (None, Parentheses, WrongChar, DivideByZero);

const
  SErrorType: array [TEvaluationError] of string = ('None', 'Parentheses', 'Wrong Char', 'Divide By Zero');

Type
  TExprEval = record
  private
    FEvaluationError: TEvaluationError;
    FErrorPos: PChar;
    FParenthesesCount: Integer;
    function ParseAtom(var expr: PChar): Double;
    function ParseFactors(var expr: PChar): Double;
    function ParseSummands(var expr: PChar): Double;
    function GetErrorType: string;
  public
    function Evaluate(var aExpression: PChar): Double; overload;
    function Evaluate(const aExpression: string): Double; overload;
    property ErrorType: string read GetErrorType;
    property EvaluationError: TEvaluationError read FEvaluationError;
    property ErrPos: PChar read FErrorPos;
  end;

implementation

var
  InternalSettings: TFormatSettings;

  { TExprEval }

function strtod(str: PChar; var endptr: PChar): Double; inline;
var
  p: PChar;
  s: String;
begin
  if (endptr = nil) or (endptr^ = #0) then
  begin
    endptr := str;
    if not TryStrToFloat(s, Result, InternalSettings) then
      Exit(0)
    else
      Exit;
  end;

  p := str;
  while p^ = #32 do
    inc(p);

  if CharInSet(p^, ['+', '-']) then
    inc(p);

  while CharInSet(p^, ['0' .. '9', '.', 'e', 'E']) do
    inc(p);

  SetString(s, str, p - str);

  if not TryStrToFloat(s, Result, InternalSettings) then
    Exit(0);

  endptr := p;
end;

function TExprEval.Evaluate(var aExpression: PChar): Double;
begin
  FParenthesesCount := 0;
  FEvaluationError := None;

  while aExpression^ = #32 do
    inc(aExpression);

  Result := ParseSummands(aExpression);

  // Now, expr should point to '#0', and FParenthesesCount should be zero
  if (FParenthesesCount <> 0) or (aExpression^ = ')') then
  begin
    FEvaluationError := TEvaluationError.Parentheses;
    FErrorPos := aExpression;
    Exit(0);
  end;

  if aExpression^ <> #0 then
  begin
    FEvaluationError := TEvaluationError.WrongChar;
    FErrorPos := aExpression;
    Exit(0);
  end;

  if FEvaluationError <> TEvaluationError.None then
    Exit(0);

  FErrorPos := #0;
end;

function TExprEval.Evaluate(const aExpression: string): Double;
var
  p: PChar;
begin
  p := PChar(aExpression);
  Exit(Evaluate(p));
end;

function TExprEval.GetErrorType: string;
begin
  Result := SErrorType[FEvaluationError];
end;

function TExprEval.ParseAtom(var expr: PChar): Double;
var
  Negative: Boolean;
  Res: Double;
  EndPointer: PChar;
begin
  EndPointer := expr;

  // Skip spaces
  while expr^ = #32 do
    inc(expr);

  // Handle the sign before parenthesis (or before number)
  Negative := False;

  if expr^ = '-' then
  begin
    Negative := True;
    inc(expr);
  end;

  if expr^ = '+' then
    inc(expr);

  // Check if there is parenthesis
  if expr^ = '(' then
  begin
    inc(expr);
    inc(FParenthesesCount);
    Res := ParseSummands(expr);

    if expr^ <> ')' then // Unmatched opening parenthesis
    begin
      FEvaluationError := TEvaluationError.Parentheses;
      FErrorPos := expr;
      Exit(0);
    end;

    inc(expr);
    dec(FParenthesesCount);

    if Negative then
      Exit(Res * -1)
    else
      Exit(Res);
  end;

  // It should be a number; convert it to double
  Res := strtod(expr, &EndPointer);
  if EndPointer = expr then // Report error
  begin
    FEvaluationError := TEvaluationError.WrongChar;
    FErrorPos := expr;
    Exit(0);
  end;

  // Advance the pointer and return the result
  expr := EndPointer;
  if Negative then
    Exit(Res * -1)
  else
    Exit(Res);
end;

function TExprEval.ParseFactors(var expr: PChar): Double;
var
  num1, num2: Double;
  op: Char;
  pos: PChar;
begin
  num1 := ParseAtom(expr);
  while True do
  begin
    // Skip spaces
    while expr^ = #32 do
      inc(expr);

    // Save the operation and position
    op := expr^;
    pos := expr;

    if not CharInSet(op, ['/', '*', '\', '(']) then
      Exit(num1);

    if op <> '(' then
      inc(expr);

    num2 := ParseAtom(expr);

    // Perform the saved operation
    if CharInSet(op, ['/', '\']) then
    begin
      // Handle division by zero
      if num2 = 0 then
      begin
        FEvaluationError := TEvaluationError.DivideByZero;
        FErrorPos := pos;
        Exit(0);
      end;

      if op = '/' then
        num1 := num1 / num2
      else
        num1 := Trunc(num1 / num2);
    end
    else
      num1 := num1 * num2;
  end
end;

function TExprEval.ParseSummands(var expr: PChar): Double;
var
  num1, num2: Double;
  op: Char;
begin
  num1 := ParseFactors(expr);
  while True do

  begin
    // Skip spaces
    while expr^ = #32 do
      inc(expr);

    op := expr^;

    if (op <> '-') and (op <> '+') then
      Exit(num1);

    inc(expr);

    num2 := ParseFactors(expr);
    if op = '-' then
      num1 := num1 - num2
    else
      num1 := num1 + num2;
  end;
end;

initialization

InternalSettings := TFormatSettings.Invariant;

end.

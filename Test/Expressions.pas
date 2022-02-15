unit Expressions;

interface

uses
  DUnitX.TestFramework, DUnitX.Types,

  SimpleExpressionEvaluator;

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

  [TestFixture]
  Tests = class
  strict private
    procedure InternalExpressionsTest(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
  public
    [Test]
    [ExpesionTest('1234', 1234)]
    [ExpesionTest('1+2*3', 7)]
    procedure SimpleExpressions(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);

    [Test]
    [ExpesionTest('5*(4+4+1)', 45)]
    [ExpesionTest('5*(2*(1+3)+1)', 45)]
    [ExpesionTest('5*((1+3)*2+1)', 45)]

    (* Sign before parenthesis *)
    [ExpesionTest('-(2+1)*4', -12)]
    [ExpesionTest('-4*(2+1)', -12)]

    (* Parenthesis error *)
    [ExpesionTest('5*((1+3)*2+1', 0, Parentheses)]
    [ExpesionTest('5*((1+3)*2)+1)', 0, Parentheses, ')')]

    (* Implicit factor before parenthes *)
    [ExpesionTest('5(1+3)', 20)]
    [ExpesionTest('5(1+3)*2+1', 41)]
    procedure Parenthesis(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);

    [Test]
    [ExpesionTest('5 * ((1 + 3) * 2 + 1)', 45)]
    [ExpesionTest('5 - 2 * ( 3 )', -1)]
    [ExpesionTest('5 - 2 * ( ( 4 )  - 1 ) ', -1)]
    [ExpesionTest('    1234    ', 1234)]
    procedure Spaces(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);

    [Test]
    [ExpesionTest('1.5/5', 0.3)]
    [ExpesionTest('1/5e10', 2E-11)]
    [ExpesionTest('(4-3)/(4*4)', 0.0625)]
    [ExpesionTest('1/2/2', 0.25)]
    [ExpesionTest('0.25 * .5 * 0.5', 0.0625)]
    [ExpesionTest('.25 / 2 * .5', 0.0625)]
    procedure FractionalNumbers(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);

    [Test]
    [ExpesionTest('5*/2', 0, WrongChar, '/2')]
    procedure RepeatedOperators(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);

    [Test]
    [ExpesionTest('*2', 0, WrongChar, '*2')]
    [ExpesionTest('2+', 0, WrongChar)]
    [ExpesionTest('2*', 0, WrongChar)]
    procedure WrongOperatorPosition(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);

    [Test]
    [ExpesionTest('2/0', 0, DivideByZero, '/0')]
    [ExpesionTest('3+1/(5-5)+4', 0, DivideByZero, '/(5-5)+4')]
    // Erroneously detected as division by zero, but that's ok for us
    [ExpesionTest('2/', 0, DivideByZero, '/')]
    procedure DivisionByZero(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);

    [Test]
    [ExpesionTest('~5', 0, WrongChar, '~5')]
    [ExpesionTest('5x', 0, WrongChar, 'x')]
    procedure InvalidCharacters(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);

    [Test]
    // Only one error will be detected (in this case, the last one)
    [ExpesionTest('3+1/0+4$', 0, WrongChar, '$')]
    [ExpesionTest('3+1/0+4', 0, DivideByZero, '/0+4')]
    [ExpesionTest('q+1/0)', 0, WrongChar, 'q+1/0)')]
    [ExpesionTest('+1/0)', 0, Parentheses, ')')]
    [ExpesionTest('+1/0', 0, DivideByZero, '/0')]
    procedure MultipleErrors(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);

    [Test]
    [ExpesionTest('', 0, WrongChar)]
    [ExpesionTest('   ', 0, WrongChar)]
    procedure EmptyString(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);

    [Test]
    [ExpesionTest('3\2', 1)]
    [ExpesionTest('2+3\2', 3)]
    [ExpesionTest('3*3\3', 3)]
    procedure DivTest(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
  end;

implementation

uses
  System.Rtti, System.Sysutils;

type
  TEvaluationErrorHelper = record helper for TEvaluationError
  private
    function GetAsString: string;
    procedure SetAsString(const Value: string);
  public
    property AsString: string read GetAsString write SetAsString;
  end;

procedure Tests.InternalExpressionsTest(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
var
  ExprEval: TExprEval;
  LResult: Double;
  LErrPos: string;
  EvaluationError: TEvaluationError;
begin
  EvaluationError.AsString := aEvaluationError;
  LResult := ExprEval.Evaluate(aExpressions);
  LErrPos := ExprEval.ErrPos;

  Assert.AreEqual(LResult, aResult);
  Assert.AreEqual(ExprEval.EvaluationError, EvaluationError);
  Assert.AreEqual(LErrPos, aErrorPos.Trim);
end;

{$REGION 'Proxy procedures'}


procedure Tests.DivisionByZero(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

procedure Tests.EmptyString(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

procedure Tests.FractionalNumbers(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

procedure Tests.InvalidCharacters(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

procedure Tests.MultipleErrors(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

procedure Tests.Parenthesis(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

procedure Tests.RepeatedOperators(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

procedure Tests.SimpleExpressions(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

procedure Tests.Spaces(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

procedure Tests.WrongOperatorPosition(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

procedure Tests.DivTest(const aExpressions: string; const aResult: Double; const aEvaluationError: string; aErrorPos: string);
begin
  InternalExpressionsTest(aExpressions, aResult, aEvaluationError, aErrorPos);
end;

{$ENDREGION}

{$REGION 'Expesion TestAttribute'}
{ ExpesionTestAttribute }

constructor ExpesionTestAttribute.Create(const aExpresstion: string; const aExpectedResult: Double; aEvaluationError: TEvaluationError; aErrorPos: string);
begin
  inherited Create;
  SetLength(FCaseInfo.Values, 4);
  FCaseInfo.Values[0] := aExpresstion;
  FCaseInfo.Values[1] := aExpectedResult.ToString;
  FCaseInfo.Values[2] := aEvaluationError.AsString;
  FCaseInfo.Values[3] := aErrorPos;

  FCaseInfo.Name := ' "' + GetValues[0].AsString.Trim + '" = ' + GetValues[1].AsString.Trim + ',  EvaluationError = ' +
    GetValues[2].AsString + ', ErrorPos = "' + GetValues[3].AsString.Trim + '"';
end;

function ExpesionTestAttribute.GetCaseInfo: TestCaseInfo;
begin
  Result := FCaseInfo;
end;

function ExpesionTestAttribute.GetName: string;
begin
  Result := FCaseInfo.Name;
end;

function ExpesionTestAttribute.GetValues: TValueArray;
begin
  Result := FCaseInfo.Values;
end;
{$ENDREGION}

{$REGION 'TEvaluationErrorHelper Implementation'}
{ TEvaluationErrorHelper }

function TEvaluationErrorHelper.GetAsString: string;
begin
  Result := TRttiEnumerationType.GetName<TEvaluationError>(Self);
end;

procedure TEvaluationErrorHelper.SetAsString(const Value: string);
begin
  Self := TRttiEnumerationType.GetValue<TEvaluationError>(Value.Trim);
end;
{$ENDREGION}

initialization

TDUnitX.RegisterTestFixture(Tests);

end.

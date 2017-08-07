unit DigFilters;

interface

function MedianFilter(SpikeHeight: double; WorkData: Array of Double): TArray<Double>;
function DigFilter(aInputData: Array of Double; CutOff: double; aSampleRate: double): TArray<Double>;

implementation

//-------------------------[  DigFilter  ]-------------------------
// Replaces single data point spikes with an average value of the 
// data points that immediatly preceed and proceed the location of 
// the spike
//-----------------------------------------------------------------
function MedianFilter(SpikeHeight: double; aInputData: Array of Double): TArray<Double>;
var i : integer;
    minPnt, maxPnt: integer;
    pnt: double;
begin
  minPnt := 0;
  maxPnt := high(aInputData);
  SetLength(result, length(aInputData));
  for i := minPnt to maxPnt do
    result[i] := aInputData[i];
  for i := (minPnt + 1) to (maxPnt - 1) do
  begin
    if abs(result[i] - result[i - 1]) > SpikeHeight then
      if abs(result[i + 1] - result[i]) > SpikeHeight then
        result[i] := (result[i + 1] + result[i - 1]) / 2;
  end;
end;

//-------------------------[  DigFilter  ]-------------------------
// Digital filter with zero phase shift.
//  CutOff is in Hz
//  aSampleRate is in kHz
//-----------------------------------------------------------------
function DigFilter(aInputData: Array of Double; CutOff: double; aSampleRate: double): TArray<Double>;
var
  wd, wa,
  a1, a2,
  b0, b1, b2,
  x0, x1, x2,
  y1: double;
  TmpStr: String;
  i: Integer;
  DeltaT: double;
  intCutOff: integer;
  StPt, EndPt: integer
Begin
  SetLength(result, length(aInputData));
  for i := 0 to high(aInputData) do
    result[i] := aInputData[i];
  DeltaT := 1.0 / (aSampleRate * 1000);
  wd := 2.0 * Pi * CutOff * 1.25 * 1.65;
  wa := sin(wd * DeltaT / 2.0) / cos(wd * DeltaT / 2.0);
  b0 := sqr(wa) / (1.0 + sqrt(2.0) * wa + sqr(wa));
  b1 := 2.0 * b0;
  b2 := b0;
  a1 := -2.0 * (sqr(wa) - 1.0) / (1.0 + sqrt(2.0) * wa + sqr(wa));
  a2 := (-1.0 + sqrt(2.0) * wa - sqr(wa)) / (1.0 + sqrt(2.0) * wa + sqr(wa));

//     ####  filter forward  #### 
  y1 := 0.0;
  for i := StPt to (StPt+9) do
    y1 := y1 + result[i];
  y1 := y1 / 10.0;
  x2 := 0.0;
  x1 := result[StPt];
  x0 := result[StPt+1];
  result[StPt]   := y1;
  result[StPt+1] := y1;
  for i := StPt+2 to EndPt do
  begin
    x2 := x1;
    x1 := x0;
    x0 := result[i];
    result[i] := (b0 * x0) + (b1 * x1) + (b2 * x2) + (a1 * result[i-1]) + (a2 * result[i-2]);
  end;

// ####  filter backward ####
  y1 := 0.0;
  for i := EndPt downto (EndPt-9) do 
    y1 := y1 + result[i];
  y1 := y1 / 10.0;
  x2 := 0.0;
  x1 := result[EndPt];
  x0 := result[EndPt-1];

  result[EndPt]   := y1;
  result[EndPt-1] := y1;

  for i := (EndPt-2) downto StPt do
  begin
    x2 := x1;
    x1 := x0;
    x0 := result[i];
    result[i] := (b0 * x0) + (b1 * x1) + (b2 * x2) + (a1 * result[i+1]) + (a2 * result[i+2]);
  end;
end; // procedure DigFilter }

initialization

end.
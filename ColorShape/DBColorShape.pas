unit DBColorShape;

interface

uses ColorShape, DB, DBCtrls, Classes, Graphics;

type
TDBColorShape = class(TColorShape)
private
    FDataLink : TFieldDataLink;
    FDataField: String;
    FDataSource: TDataSource;
    procedure SetDataField(const Value: String);
    procedure SetDataSource(const Value: TDataSource);
    function GetDataField: String;
    function GetDataSource: TDataSource;

protected
  procedure DataChange(Sender : TObject);
  procedure SetColor(value: TColor); Override;
public
  constructor Create(AOwner : TComponent); override;
  destructor Destroy; override;
published
  property DataField : String read GetDataField write SetDataField;
  property DataSource : TDataSource read GetDataSource write SetDataSource;
end;


procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('ERG Lib', [TDBColorShape]);
end;

{ TDBColorShape }

constructor TDBColorShape.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.OnDataChange := DataChange;
end;

procedure TDBColorShape.DataChange(Sender: TObject);
begin
  if FDataLink.Field = nil then
  begin
    Color := 0;
  end else
  begin
    Color := FDataLink.Field.AsInteger;
  end;
end;

destructor TDBColorShape.Destroy;
begin
  FDataLink.OnDataChange := nil;
  FDataLink.Free;
  FDataLink := nil;
  inherited;
end;

function TDBColorShape.GetDataField: String;
begin
  Result := FDataLink.FieldName;
end;

function TDBColorShape.GetDataSource: TDataSource;
begin
  Result := FDatalink.DataSource;
end;

procedure TDBColorShape.SetColor(value: TColor);
begin
  inherited;
  if not (csLoading in ComponentState) then
  begin
    try
      if FDataLink.Field = nil then
      begin
      end else
      begin
        FDataLink.Field.AsInteger := Color;
      end;
    except
    end;
  end;
end;

procedure TDBColorShape.SetDataField(const Value: String);
begin
  FDataLink.FieldName := Value;
end;

procedure TDBColorShape.SetDataSource(const Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

end.

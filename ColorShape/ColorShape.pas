unit ColorShape;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, ExtCtrls, StdCtrls, Graphics;

type
  TClickEvent = procedure (Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer) of object;

  TColorShape = class(TShape)
  private
    FMyLabel : TBoundLabel;
    FLabelSpacing: Integer;
    FLabelPosition: TLabelPosition;
    FColor: TColor;
    procedure SetLabelPosition(const Value: TLabelPosition);
    procedure SetLabelSpacing(const Value: Integer);
    function GetColor: TColor;
    { Private declarations }
  protected
    { Protected declarations }
    clickChain : TClickEvent;
    procedure myClickEvent(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure SetName(const Value : TComponentName);override;
    procedure SetParent(AParent : TWinControl); override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CMVisiblechanged(var Message: TMessage);
      message CM_VISIBLECHANGED;
    procedure CMEnabledchanged(var Message: TMessage);
      message CM_ENABLEDCHANGED;
    procedure CMBidimodechanged(var Message: TMessage);
      message CM_BIDIMODECHANGED;
    procedure SetColor(value : TColor); virtual;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
    procedure SetupInternalLabel;

  published
    { Published declarations }
    property ColorLabel : TBoundLabel read FMyLabel;
    property Color : TColor read GetColor write SetColor;
    property LabelPosition: TLabelPosition read FLabelPosition write SetLabelPosition;
    property LabelSpacing: Integer read FLabelSpacing write SetLabelSpacing;

  end;

procedure Register;

implementation

uses Inifiles, Forms, Dialogs;

procedure Register;
begin
  RegisterComponents('ERG Lib', [TColorShape]);
end;

{ TColorShape }

procedure TColorShape.CMBidimodechanged(var Message: TMessage);
begin
  inherited;
  FMyLabel.BiDiMode := BiDiMode;
end;

procedure TColorShape.CMEnabledchanged(var Message: TMessage);
begin
  inherited;
  FMyLabel.Enabled := Enabled;
end;

procedure TColorShape.CMVisiblechanged(var Message: TMessage);
begin
  inherited;
  FMyLabel.Visible := Visible;
end;

constructor TColorShape.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FLabelPosition := lpAbove;
  FLabelSpacing := 3;
  SetupInternalLabel;
end;

destructor TColorShape.Destroy;
begin

  inherited;
end;

function TColorShape.GetColor: TColor;
begin
  result := Brush.Color;
end;

procedure TColorShape.Loaded;
var s : string;
begin
  inherited;
  s := application.Exename;
  s := copy(s,1,length(s) - 3) + 'ini';
  with TInifile.Create(s) do
  begin
    try
      Self.Brush.Color := ReadInteger('Variables', Self.Name + 'Color', Brush.Color);
    finally
      Free;
    end;
  end;
  ClickChain := Self.OnMouseDown;
  Self.OnMouseDown := myClickEvent;
end;

procedure TColorShape.myClickEvent(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var cd : TColorDialog;
    s : string;
begin
  cd := TColorDialog.Create(nil);
  s := Application.ExeName;
  s := copy(s,1,length(s) - 3) + 'Colors';
  if FileExists(s) then
  begin
    cd.CustomColors.LoadFromFile(s);
  end;
  try
    cd.options := [cdFullOpen, cdShowHelp];
    cd.Color := self.Brush.color;
    if cd.Execute then
    begin
      Self.Color := cd.Color;
      s := Application.ExeName;
      s := copy(s,1,length(s) - 3) + 'ini';
      with TInifile.Create(S) do
      begin
        try
          WriteInteger('Variables', Self.Name + 'Color',Self.Brush.Color);
        finally
          Free;
        end;
      end;
      s := Application.ExeName;
      s := copy(s,1,length(s) - 3) + 'Colors';
      cd.CustomColors.SaveToFile(s);
    end;
  finally
    cd.Free;
  end;
  if assigned(clickChain) then
  begin
    clickChain(Sender,Button,Shift,X,Y);
  end;
end;

procedure TColorShape.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FMyLabel) and (Operation = opRemove) then
    FMyLabel := nil;
end;

procedure TColorShape.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  SetLabelPosition(FLabelPosition);
end;

procedure TColorShape.SetColor(value: TColor);
begin
  FColor := Value;
  Brush.Color := Value;
end;

procedure TColorShape.SetLabelPosition(const Value: TLabelPosition);
var
  P: TPoint;
begin
  if FMyLabel = nil then exit;
  FLabelPosition := Value;
  case Value of
    lpAbove: begin
                P.x := left;
                p.y := Top - FMyLabel.Height - FLabelSpacing;
             end;
    lpBelow: begin
        P.x := Left;
        p.y := Top + Height + FLabelSpacing;
    end;
    lpLeft : begin
       P.x := Left - FMyLabel.Width - FLabelSpacing;
       p.y := Top + ((Height - FMyLabel.Height) div 2);
    end;
    lpRight: begin
      P.x := Left + Width + FLabelSpacing;
      p.y := Top + ((Height - FMyLabel.Height) div 2);
    end;
  end;
  FMyLabel.SetBounds(P.x, P.y, FMyLabel.Width, FMyLabel.Height);
end;

procedure TColorShape.SetLabelSpacing(const Value: Integer);
begin
  FLabelSpacing := Value;
  SetLabelPosition(FLabelPosition);
end;

procedure TColorShape.SetName(const Value: TComponentName);
begin
  if (csDesigning in ComponentState) and ((FMylabel.GetTextLen = 0) or
     (CompareText(FMyLabel.Caption, Name) = 0)) then
    FMyLabel.Caption := Value;
  inherited SetName(Value);
  if csDesigning in ComponentState then
    Text := '';
end;

procedure TColorShape.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if FMyLabel = nil then exit;
  FMyLabel.Parent := AParent;
  FMyLabel.Visible := True;
end;

procedure TColorShape.SetupInternalLabel;
begin
  if Assigned(FMyLabel) then exit;
  FMyLabel := TBoundLabel.Create(Self);
  FMyLabel.FreeNotification(Self);
//  FMyLabel.FocusControl := Self;
end;

end.

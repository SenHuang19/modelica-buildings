within Buildings.Controls.OBC.CDL.Integers.Validation;
model Less "Validation model for the Less block"
extends Modelica.Icons.Example;

  Buildings.Controls.OBC.CDL.Continuous.Sources.Ramp ramp1(
    duration=1,
    offset=-3.5,
    height=10.0) "Block that generates ramp signal"
    annotation (Placement(transformation(extent={{-80,10},{-60,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Ramp ramp2(
    duration=1,
    offset=-1.5,
    height=5.0) "Block that generates ramp signal"
    annotation (Placement(transformation(extent={{-80,-30},{-60,-10}})));
  Buildings.Controls.OBC.CDL.Integers.Less intLes
    "Block output true if input 1 is less than input 2"
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));

  Buildings.Controls.OBC.CDL.Continuous.Round round1(n=0)
    "Round real number to given digits"
    annotation (Placement(transformation(extent={{-40,10},{-20,30}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt
    "Convert real to integer"
    annotation (Placement(transformation(extent={{0,10},{20,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Round round2(n=0)
    "Round real number to given digits"
    annotation (Placement(transformation(extent={{-40,-30},{-20,-10}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt1
    "Convert real to integer"
    annotation (Placement(transformation(extent={{0,-30},{20,-10}})));

equation
  connect(ramp1.y, round1.u)
    annotation (Line(points={{-59,20},{-42,20}}, color={0,0,127}));
  connect(round1.y, reaToInt.u)
    annotation (Line(points={{-19,20},{-2,20}}, color={0,0,127}));
  connect(ramp2.y, round2.u)
    annotation (Line(points={{-59,-20},{-42,-20}}, color={0,0,127}));
  connect(round2.y, reaToInt1.u)
    annotation (Line(points={{-19,-20},{-12,-20},{-12,-20},{-2,-20}},
      color={0,0,127}));
  connect(reaToInt1.y, intLes.u2)
    annotation (Line(points={{21,-20},{40,-20},{40,-8},{58,-8}},
      color={255,127,0}));
  connect(reaToInt.y, intLes.u1)
    annotation (Line(points={{21,20},{40,20},{40,0},{58,0}},
      color={255,127,0}));

annotation (
  experiment(StopTime=1.0, Tolerance=1e-06),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Controls/OBC/CDL/Integers/Validation/Less.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
Validation test for the block
<a href=\"modelica://Buildings.Controls.OBC.CDL.Integers.Less\">
Buildings.Controls.OBC.CDL.Integers.Less</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
August 30, 2017, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>

</html>"));
end Less;
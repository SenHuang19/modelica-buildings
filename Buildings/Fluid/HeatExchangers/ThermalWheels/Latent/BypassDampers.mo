within Buildings.Fluid.HeatExchangers.ThermalWheels.Latent;
model BypassDampers
  "Enthalpy recovery wheel with bypass dampers"
  extends Buildings.Fluid.HeatExchangers.ThermalWheels.Latent.BaseClasses.PartialWheel;

  parameter Modelica.Units.SI.PressureDifference dpDamper_nominal(displayUnit="Pa") = 20
    "Nominal pressure drop of dampers"
    annotation (Dialog(group="Nominal condition"));

  parameter Boolean use_strokeTime=true
    "Set to true to continuously open and close valve using strokeTime"
    annotation (Dialog(tab="Dynamics", group="Actuator position"));
  parameter Modelica.Units.SI.Time strokeTime=120
    "Time needed to fully open or close actuator"
    annotation (Dialog(tab="Dynamics", group="Actuator position", enable=use_strokeTime));
  parameter Modelica.Blocks.Types.Init init=Modelica.Blocks.Types.Init.InitialOutput
    "Type of initialization (no init/steady state/initial state/initial output)"
    annotation (Dialog(tab="Dynamics", group="Actuator position", enable=use_strokeTime));
  parameter Real yMai_start=0 "Initial position of supply and exhaust actuator"
    annotation (Dialog(tab="Dynamics", group="Actuator position", enable=use_strokeTime));
  parameter Real yByp_start=1 "Initial position of bypass actuators"
    annotation (Dialog(tab="Dynamics", group="Actuator position", enable=use_strokeTime));

  Buildings.Controls.OBC.CDL.Interfaces.RealInput uBypDamPos(
    final unit="1",
    final min=0,
    final max=1)
    "Bypass damper position"
    annotation (Placement(transformation(extent={{-220,120},{-180,160}}),
      iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uRot
    "True when the wheel is operating"
    annotation (Placement(transformation(extent={{-220,-20},{-180,20}}),
      iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Fluid.Actuators.Dampers.Exponential bypDamSup(
    redeclare package Medium = Medium,
    final m_flow_nominal=per.mSup_flow_nominal,
    final use_strokeTime=use_strokeTime,
    final strokeTime=strokeTime,
    final init=init,
    final y_start=yByp_start,
    final dpDamper_nominal=dpDamper_nominal)
    "Supply air bypass damper"
    annotation (Placement(transformation(extent={{-48,70},{-28,90}})));
  Buildings.Fluid.Actuators.Dampers.Exponential damSup(
    redeclare package Medium = Medium,
    final m_flow_nominal=per.mSup_flow_nominal,
    final use_strokeTime=use_strokeTime,
    final strokeTime=strokeTime,
    final init=init,
    final y_start=yMai_start,
    final dpDamper_nominal=dpDamper_nominal)
    "Supply air damper"
    annotation (Placement(transformation(
    extent={{-10,-10},{10,10}},rotation=0,origin={-90,36})));
  Buildings.Fluid.Actuators.Dampers.Exponential damExh(
    redeclare package Medium = Medium,
    final m_flow_nominal=per.mExh_flow_nominal,
    final use_strokeTime=use_strokeTime,
    final strokeTime=strokeTime,
    final init=init,
    final y_start=yMai_start,
    final dpDamper_nominal=dpDamper_nominal)
    "Exhaust air damper"
    annotation (Placement(transformation(
    extent={{10,10},{-10,-10}},rotation=-90,origin={40,-44})));
  Buildings.Fluid.Actuators.Dampers.Exponential bypDamExh(
    redeclare package Medium = Medium,
    final m_flow_nominal=per.mExh_flow_nominal,
    final use_strokeTime=use_strokeTime,
    final strokeTime=strokeTime,
    final init=init,
    final y_start=yByp_start,
    final dpDamper_nominal=dpDamper_nominal)
    "Exhaust air bypass damper"
    annotation (Placement(transformation(extent={{0,-90},{-20,-70}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swiEpsSen
    "Switch the sensible heat exchanger effectiveness based on the wheel operation status"
    annotation (Placement(transformation(extent={{-40,150},{-20,170}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swiEpsLat
    "Switch the latent heat exchanger effectiveness based on the wheel operation status"
    annotation (Placement(transformation(extent={{-40,120},{-20,140}})));

protected
  Modelica.Blocks.Sources.Constant uni(
    final k=1)
    "Unity signal"
    annotation (Placement(transformation(extent={{-140,110},{-120,130}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Difference of the two inputs"
    annotation (Placement(transformation(extent={{-100,90},{-80,110}})));
  Modelica.Blocks.Math.BooleanToReal PEle(
    final realTrue=per.P_nominal,
    final realFalse=0)
    "Electric power consumption for motor"
    annotation (Placement(transformation(extent={{-120,-110},{-100,-90}})));
  Modelica.Blocks.Sources.Constant zero(final k=0)
    "Zero signal"
    annotation (Placement(transformation(extent={{-140,150},{-120,170}})));

initial equation
  assert(not per.haveVariableSpeed,
         "In " + getInstanceName() + ": The performance data record
         is wrong, the variable speed flag must be false",
         level=AssertionLevel.error)
         "Check if the performance data record is correct";

equation
  connect(sub.y, damSup.y)
    annotation (Line(points={{-78,100},{0,100},{0,54},{-90,54},{-90,48}},
    color={0,0,127}));
  connect(damExh.y,sub. y)
    annotation (Line(points={{28,-44},{0,-44},{0,100},{-78,100}},   color={0,0,127}));
  connect(bypDamSup.y, uBypDamPos)
    annotation (Line(points={{-38,92},{-38,98},{-72,98},{-72,84},{-160,84},{-160,
          140},{-200,140}},color={0,0,127}));
  connect(damSup.port_b, hex.port_a1)
    annotation (Line(points={{-80,36},{-30,36},{-30,6},{10,6}},
    color={0,127,255},
      thickness=0.5));
  connect(bypDamExh.y, uBypDamPos)
    annotation (Line(points={{-10,-68},{-10,-24},{-114,-24},{-114,84},{-160,84},
          {-160,140},{-200,140}},
    color={0,0,127}));
  connect(sub.u2, uBypDamPos)
    annotation (Line(points={{-102,94},{-160,94},{-160,140},{-200,140}},
    color={0,0,127}));
  connect(uni.y, sub.u1)
    annotation (Line(points={{-119,120},{-110,120},{-110,106},{-102,106}},
    color={0,0,127}));
  connect(PEle.y, P) annotation (Line(points={{-99,-100},{80,-100},{80,-40},{
          120,-40}},
          color={0,0,127}));
  connect(damSup.port_a, port_a1) annotation (Line(points={{-100,36},{-130,36},{-130,80},{-180,80}},
    color={0,127,255},
      thickness=0.5));
  connect(damExh.port_b, hex.port_a2)
    annotation (Line(points={{40,-34},{40,-6},{30,-6}}, color={0,127,255},
      thickness=0.5));
  connect(bypDamExh.port_b, port_b2)
    annotation (Line(points={{-20,-80},{-180,-80}},
    color={0,127,255},
      thickness=0.5));
  connect(damExh.port_a, port_a2)
    annotation (Line(points={{40,-54},{40,-80},{100,-80}}, color={0,127,255},
      thickness=0.5));
  connect(bypDamExh.port_a, port_a2)
    annotation (Line(points={{0,-80},{100,-80}},
    color={0,127,255},
      thickness=0.5));
  connect(bypDamSup.port_b, port_b1)
    annotation (Line(points={{-28,80},{100,80}}, color={0,127,255},
      thickness=0.5));
  connect(bypDamSup.port_a, port_a1)
    annotation (Line(points={{-48,80},{-180,80}}, color={0,127,255},
      thickness=0.5));
  connect(zero.y,swiEpsSen. u3) annotation (Line(points={{-119,160},{-60,160},{-60,
          152},{-42,152}}, color={0,0,127}));
  connect(swiEpsLat.u3, zero.y) annotation (Line(points={{-42,122},{-60,122},{-60,
          160},{-119,160}}, color={0,0,127}));
  connect(effCal.epsSen,swiEpsSen. u1) annotation (Line(points={{-78,5},{-68,5},
          {-68,168},{-42,168}}, color={0,0,127}));
  connect(effCal.epsLat,swiEpsLat. u1) annotation (Line(points={{-78,-5},{-64,-5},
          {-64,138},{-42,138}}, color={0,0,127}));
  connect(swiEpsSen.u2, uRot) annotation (Line(points={{-42,160},{-52,160},{-52,
          176},{-168,176},{-168,0},{-200,0}}, color={255,0,255}));
  connect(swiEpsLat.u2, uRot) annotation (Line(points={{-42,130},{-52,130},{-52,
          176},{-168,176},{-168,0},{-200,0}}, color={255,0,255}));
  connect(swiEpsSen.y, hex.epsSen) annotation (Line(points={{-18,160},{-6,160},{
          -6,3},{8,3}}, color={0,0,127}));
  connect(swiEpsLat.y, hex.epsLat) annotation (Line(points={{-18,130},{-10,130},
          {-10,-3},{8,-3}}, color={0,0,127}));
  connect(swiEpsSen.y, epsSen) annotation (Line(points={{-18,160},{40,160},{40,40},
          {120,40}},     color={0,0,127}));
  connect(swiEpsLat.y, epsLat) annotation (Line(points={{-18,130},{88,130},{88,0},
          {120,0}}, color={0,0,127}));
  connect(PEle.u, uRot) annotation (Line(points={{-122,-100},{-168,-100},{-168,
          0},{-200,0}},
                     color={255,0,255}));
annotation (
        defaultComponentName="whe",
        Icon(coordinateSystem(extent={{-100,-100},{100,100}}),
        graphics={
        Polygon(
          points={{0,100},{0,100}},
          lineColor={28,108,200},
          fillColor={255,255,255},
          fillPattern=FillPattern.None),
        Rectangle(
          extent={{-60,100},{62,96}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          lineThickness=0.5),
        Rectangle(
          extent={{-11,4},{11,-4}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          origin={58,87},
          rotation=90),
        Rectangle(
          extent={{-11.5,3.5},{11.5,-3.5}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          origin={-56.5,87.5},
          rotation=90),
        Rectangle(
          extent={{-9,3},{9,-3}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          origin={-55,-85},
          rotation=90),
        Rectangle(
          extent={{-9,4},{9,-4}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          origin={60,-85},
          rotation=90),
        Rectangle(
          extent={{-58,-92},{64,-96}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          lineThickness=0.5)}),
          Diagram(
        coordinateSystem(preserveAspectRatio=true, extent={{-180,-120},{100,180}})),
Documentation(info="<html>
<p>
Model of an enthalpy recovery wheel, which consists of
a heat exchanger and two dampers to bypass the supply and exhaust airflow.
</p>
<p>
This model does not require geometric data. The performance is defined by specifying
the part load (75% of the nominal supply flow rate) and nominal sensible and latent
heat exchanger effectiveness.
This operation of the wheel is configured as follows.
</p>
<ul>
<li>
If the operating signal <code>uRot=true</code>,
<ul>
<li>
The wheel power consumption is constant and equal to the nominal value.
</li>
<li>
The heat exchange in the heat recovery wheel is adjustable via bypassing supply/exhaust air
through the heat exchanger.
Accordingly, the sensible and latent heat exchanger effectiveness are calculated with
<a href=\"modelica://Buildings.Fluid.HeatExchangers.ThermalWheels.Latent.BaseClasses.Effectiveness\">
Buildings.Fluid.HeatExchangers.ThermalWheels.Latent.BaseClasses.Effectiveness</a>.
</li>
</ul>
</li>
<li>
Otherwise,
<ul>
<li>
The wheel power consumption is 0.
</li>
<li>
In addition, there is no sensible or latent heat transfer, i.e., the sensible
and latent effectiveness of the heat recovery wheel is 0.
</li>
</ul>
</li>
</ul>
</html>", revisions="<html>
<ul>
<li>
September 29, 2023, by Sen Huang:<br/>
First implementation.
</li>
</ul>
</html>"));
end BypassDampers;

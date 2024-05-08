within Buildings.Fluid.HeatExchangers.ThermalWheels.Sensible.BaseClasses;
partial model PartialWheel
  "Partial model for sensible heat recovery wheel"
  extends Modelica.Blocks.Icons.Block;
  replaceable package Medium =
    Modelica.Media.Interfaces.PartialCondensingGases
    "Air";
  parameter Modelica.Units.SI.MassFlowRate mSup_flow_nominal
    "Nominal supply air mass flow rate"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.MassFlowRate mExh_flow_nominal
    "Nominal exhaust air mass flow rate"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.PressureDifference dpSup_nominal(displayUnit="Pa") = 500
    "Nominal supply air pressure drop"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.PressureDifference dpExh_nominal(displayUnit="Pa") = dpSup_nominal
    "Nominal exhaust air pressure drop"
    annotation (Dialog(group="Nominal condition"));
  parameter Real P_nominal(final unit="W")
    "Power consumption at the design condition"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Efficiency epsCoo_nominal(
    final max=1) = 0.8
    "Nominal sensible heat exchanger effectiveness at the cooling mode"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Efficiency epsHea_nominal(
    final max=1) = 0.8
    "Nominal sensible heat exchanger effectiveness at the heating mode"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Efficiency epsCooPL(
    final max=1) = 0.75
    "Part load (75% of the nominal supply flow rate) sensible heat exchanger effectiveness at the cooling mode"
    annotation (Dialog(group="Part load effectiveness"));
  parameter Modelica.Units.SI.Efficiency epsHeaPL(
    final max=1) = 0.75
    "Part load (75% of the nominal supply flow rate) sensible heat exchanger effectiveness at the heating mode"
    annotation (Dialog(group="Part load effectiveness"));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput P(
    final unit="W") "Electric power consumption"
    annotation (Placement(transformation(extent={{100,-110},{140,-70}}),
        iconTransformation(extent={{100,-110},{140,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput eps(final unit="1")
    "Sensible heat exchanger effectiveness"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Fluid.HeatExchangers.ThermalWheels.Sensible.BaseClasses.HeatExchangerWithInputEffectiveness
    hex(
    redeclare package Medium1 = Medium,
    redeclare package Medium2 = Medium,
    final m1_flow_nominal=mSup_flow_nominal,
    final m2_flow_nominal=mExh_flow_nominal,
    final dp1_nominal=dpSup_nominal,
    final dp2_nominal=dpExh_nominal) "Heat exchanger"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a1(
    redeclare final package Medium = Medium)
    "Fluid connector a1 of the supply air (positive design flow direction is from port_a1 to port_b1)"
    annotation (Placement(transformation(extent={{-190,70},{-170,90}}),
        iconTransformation(extent={{-110,50},{-90,70}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b2(
    redeclare final package Medium = Medium)
    "Fluid connector b2 of the exhaust air (positive design flow direction is from port_a2 to port_b2)"
    annotation (Placement(transformation(extent={{-170,-70},{-190,-50}}),
        iconTransformation(extent={{-90,-70},{-110,-50}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b1(
    redeclare final package Medium = Medium)
    "Fluid connector b1 of the supply air (positive design flow direction is from port_a1 to port_b1)"
    annotation (Placement(transformation(extent={{110,70},{90,90}}),
        iconTransformation(extent={{110,50},{90,70}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a2(
    redeclare final package Medium = Medium)
    "Fluid connector a2 of the exhaust air (positive design flow direction is from port_a2 to port_b2)"
    annotation (Placement(transformation(extent={{90,-70},{110,-50}})));

  Buildings.Fluid.Sensors.MassFlowRate senSupMasFlo(
    redeclare package Medium = Medium)
    "Supply air mass flow rate"
    annotation (Placement(transformation(extent={{32,-4},{52,16}})));
  Buildings.Fluid.Sensors.MassFlowRate senExhMasFlo(
     redeclare package Medium = Medium)
    "Exhaust air mass flow rate"
    annotation (Placement(transformation(extent={{-70,-44},{-90,-24}})));
protected
  parameter Medium.ThermodynamicState sta_nominal=Medium.setState_pTX(
      T=Buildings.Utilities.Psychrometrics.Constants.T_ref,
      p=101325,
      X=Medium.X_default)
   "State of the supply air at the default properties";
  Buildings.Fluid.HeatExchangers.ThermalWheels.Sensible.BaseClasses.Effectiveness
    effCal(
    final epsCoo_nominal=epsCoo_nominal,
    final epsCooPL=epsCooPL,
    final epsHea_nominal=epsHea_nominal,
    final epsHeaPL=epsHeaPL,
    final mSup_flow_nominal=mSup_flow_nominal)
    "Calculates the effectiveness of heat exchange"
    annotation (Placement(transformation(extent={{-100,-10},{-80,10}})));
  Modelica.Blocks.Sources.RealExpression TSup(
    final y(final unit="K")=Medium.temperature(
      Medium.setState_phX(
        p=port_a1.p,
        h=inStream(port_a1.h_outflow),
        X=inStream(port_a1.Xi_outflow))))
    "Supply air temperature"
    annotation (Placement(transformation(extent={{-160,10},{-140,30}})));
  Modelica.Blocks.Sources.RealExpression TExh(
    final y(final unit="K")=Medium.temperature(
      Medium.setState_phX(
        p=port_a2.p,
        h=inStream(port_a2.h_outflow),
        X=inStream(port_a2.Xi_outflow))))
    "Exhaust air temperature"
    annotation (Placement(transformation(extent={{-160,-50},{-140,-30}})));

equation
  connect(TSup.y, effCal.TSup)
    annotation (Line(points={{-139,20},{-110,20},{-110,-4},{-102,-4}},
        color={0,0,127}));
  connect(TExh.y, effCal.TExh)
    annotation (Line(points={{-139,-40},{-110,-40},{-110,-8},{-102,-8}},
        color={0,0,127}));
  connect(effCal.eps, hex.eps)
    annotation (Line(points={{-78,0},{-12,0}}, color={0,0,127}));
  connect(effCal.eps, eps) annotation (Line(points={{-78,0},{-40,0},{-40,32},{
          80,32},{80,0},{120,0}},
                color={0,0,127}));
  connect(senExhMasFlo.port_b, port_b2) annotation (Line(points={{-90,-34},{-100,
          -34},{-100,-60},{-180,-60}}, color={0,127,255}));
  connect(senExhMasFlo.port_a, hex.port_b2) annotation (Line(points={{-70,-34},{
          -16,-34},{-16,-6},{-10,-6}}, color={0,127,255}));
  connect(hex.port_b1, senSupMasFlo.port_a)
    annotation (Line(points={{10,6},{32,6}}, color={0,127,255}));
  connect(senSupMasFlo.port_b, port_b1) annotation (Line(points={{52,6},{60,6},{
          60,80},{100,80}}, color={0,127,255}));
  connect(senExhMasFlo.m_flow, effCal.mExh_flow) annotation (Line(points={{-80,-23},
          {-80,-16},{-106,-16},{-106,4},{-102,4}}, color={0,0,127}));
  connect(senSupMasFlo.m_flow, effCal.mSup_flow) annotation (Line(points={{42,17},
          {42,26},{-106,26},{-106,8},{-102,8}}, color={0,0,127}));
annotation (
        defaultComponentName="whe",
        Icon(coordinateSystem(extent={{-100,-100},{100,100}}),
        graphics={
        Polygon(
          points={{0,100},{0,100}},
          lineColor={28,108,200},
          fillColor={255,255,255},
          fillPattern=FillPattern.None),
        Text(
          extent={{44,14},{94,-10}},
          textColor={0,0,127},
          textString="epsSen"),
        Text(
          extent={{46,-74},{96,-98}},
          textColor={0,0,127},
          textString="P"),
        Rectangle(
          extent={{26,-56},{94,-64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{32,64},{94,56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-92,-55},{-30,-64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-94,65},{-28,56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(extent={{8,78},{38,-74}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-6,78},{22,-74}},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Ellipse(
          extent={{-38,78},{-6,-74}},
          lineColor={28,108,200},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Line(points={{-22,-74},{22,-74}}, color={0,0,0}),
        Line(points={{-22,78},{22,78}}, color={0,0,0})}),
          Diagram(
        coordinateSystem(preserveAspectRatio=true, extent={{-180,-100},{100,100}})),
Documentation(info="<html>
<p>
Partial model of a sensible heat recovery wheel.
</p>
</html>", revisions="<html>
<ul>
<li>
January 8, 2023, by Sen Huang:<br/>
First implementation.
</li>
</ul>
</html>"));
end PartialWheel;

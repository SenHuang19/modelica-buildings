within Buildings.Controls.OBC.CDL.Continuous;
block PIDWithReset
  "P, PI, PD, and PID controller with limited output, anti-windup compensation and setpoint weighting"
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController controllerType=
         Buildings.Controls.OBC.CDL.Types.SimpleController.PI "Type of controller";
  parameter Real k(
    min=0) = 1 "Gain of controller";
  parameter Modelica.SIunits.Time Ti(min=Constants.small) = 0.5
    "Time constant of integrator block"
    annotation (Dialog(enable=
          controllerType == CDL.Types.SimpleController.PI or
          controllerType == CDL.Types.SimpleController.PID));
  parameter Modelica.SIunits.Time Td(
    min=0) = 0.1
    "Time constant of derivative block"
    annotation (Dialog(enable=
          controllerType == CDL.Types.SimpleController.PD or
          controllerType == CDL.Types.SimpleController.PID));
  parameter Real yMax = 1 "Upper limit of output";
  parameter Real yMin = 0 "Lower limit of output";
  parameter Real wp(min=0) = 1 "Set-point weight for Proportional block (0..1)";
  parameter Real wd(min=0) = 0 "Set-point weight for Derivative block (0..1)"
       annotation(Dialog(enable=controllerType==CDL.Types.SimpleController.PD or
                                controllerType==CDL.Types.SimpleController.PID));
  parameter Real Ni(min=100*Modelica.Constants.eps) = 0.9
    "Ni*Ti is time constant of anti-windup compensation"
     annotation(Dialog(enable=controllerType==CDL.Types.SimpleController.PI or
                              controllerType==CDL.Types.SimpleController.PID));
  parameter Real Nd(min=100*Modelica.Constants.eps) = 10
    "The higher Nd, the more ideal the derivative block"
       annotation(Dialog(enable=controllerType==CDL.Types.SimpleController.PD or
                                controllerType==CDL.Types.SimpleController.PID));

  parameter Real xi_start=0
    "Initial value of integrator state"
    annotation (Dialog(
      group="Initialization",
      enable=
       controllerType==CDL.Types.SimpleController.PI or
       controllerType==CDL.Types.SimpleController.PID));
  parameter Real yd_start=0 "Initial value of derivative output"
  annotation(Dialog(
      group="Initialization",
      enable=
        controllerType==CDL.Types.SimpleController.PD or
        controllerType==CDL.Types.SimpleController.PID));
  parameter Boolean reverseActing = true
    "Set to true for reverse acting, or false for direct acting control action";
  parameter Real y_reset=xi_start
    "Value to which the controller output is reset if the boolean trigger has a rising edge"
    annotation(Dialog(enable=
      controllerType==CDL.Types.SimpleController.PI or
      controllerType==CDL.Types.SimpleController.PID, group="Integrator reset"));

  Buildings.Controls.OBC.CDL.Interfaces.RealInput u_s
    "Connector of setpoint input signal"
    annotation (Placement(transformation(extent={{-260,-20},{-220,20}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput u_m
    "Connector of measurement input signal"
    annotation (Placement(transformation(origin={0,-220}, extent={{20,-20},{-20,20}},
      rotation=270), iconTransformation(extent={{20,-20},{-20,20}},
        rotation=270, origin={0,-120})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput y
    "Connector of actuator output signal"
    annotation (Placement(transformation(extent={{220,-20},{260,20}}),
        iconTransformation(extent={{100,-20},{140,20}})));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput trigger
    "Resets the controller output when trigger becomes true"
    annotation (Placement(transformation(extent={{-20,-20},{20,20}},
        rotation=90, origin={-160,-220}),
      iconTransformation(extent={{-20,-20},{20,20}}, rotation=90, origin={-60,-120})));

  Buildings.Controls.OBC.CDL.Continuous.Feedback controlError "Control error (set point - measurement)"
    annotation (Placement(transformation(extent={{-200,-10},{-180,10}})));

  Buildings.Controls.OBC.CDL.Continuous.IntegratorWithReset I(
    final k=1/Ti,
    final y_start=xi_start) if with_I "Integral term"
    annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));

  Derivative D(
    final k=Td,
    final T=Td/Nd,
    final y_start=yd_start) if with_D "Derivative term"
    annotation (Placement(transformation(extent={{-40,60},{-20,80}})));

  Buildings.Controls.OBC.CDL.Continuous.Feedback errP "P error"
    annotation (Placement(transformation(extent={{-100,110},{-80,130}})));
  Buildings.Controls.OBC.CDL.Continuous.Feedback errD if with_D "D error"
    annotation (Placement(transformation(extent={{-100,60},{-80,80}})));
  Buildings.Controls.OBC.CDL.Continuous.Feedback errI1 if with_I
    "I error (before anti-windup componensation)"
    annotation (Placement(transformation(extent={{-120,-10},{-100,10}})));

  Buildings.Controls.OBC.CDL.Continuous.Feedback errI2 if with_I
    "I error (after anti-windup componensation)"
    annotation (Placement(transformation(extent={{-82,-10},{-62,10}})));

  Buildings.Controls.OBC.CDL.Continuous.Limiter lim(
    final uMax=yMax,
    final uMin=yMin)
    "Limiter"
    annotation (Placement(transformation(extent={{120,80},{140,100}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal Izero if not with_I
    "Zero input signal"
    annotation (Placement(transformation(extent={{-20,-150},{0,-130}})));

protected
  final parameter Real revAct = if reverseActing then 1 else -1
    "Switch for sign for reverse or direct acting controller";
  final parameter Boolean with_I = controllerType==Buildings.Controls.OBC.CDL.Types.SimpleController.PI or
                                   controllerType==Buildings.Controls.OBC.CDL.Types.SimpleController.PID
    "Boolean flag to enable integral action"
    annotation(Evaluate=true, HideResult=true);
  final parameter Boolean with_D = controllerType==Buildings.Controls.OBC.CDL.Types.SimpleController.PD or
                                   controllerType==Buildings.Controls.OBC.CDL.Types.SimpleController.PID
    "Boolean flag to enable derivative action"
    annotation(Evaluate=true, HideResult=true);

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant Dzero(
    final k=0) if not with_D
    "Zero input signal"
    annotation(Evaluate=true, HideResult=true,
               Placement(transformation(extent={{-40,90},{-20,110}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain uS_revAct(
    final k=revAct) "Set point multiplied by reverse action sign"
    annotation (Placement(transformation(extent={{-200,30},{-180,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain uSetWp(
    final k=wp) "Set point multiplied by weight for proportional gain"
    annotation (Placement(transformation(extent={{-160,110},{-140,130}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain uMea_revAct(
    final k=revAct) "Set point multiplied by reverse action sign"
    annotation (Placement(transformation(extent={{-180,-50},{-160,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain uSetWd(
    final k=wd) if with_D
    "Set point multiplied by weight for derivative gain"
    annotation (Placement(transformation(extent={{-160,60},{-140,80}})));
  Buildings.Controls.OBC.CDL.Continuous.Add addPD(
    final k1=1,
    final k2=1) "Outputs P and D gains added"
    annotation (Placement(transformation(extent={{0,104},{20,124}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gainPID(
    final k=k) "Multiplier for control gain"
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  Buildings.Controls.OBC.CDL.Continuous.Add addPID(
    final k1=1,
    final k2=1)
    "Outputs P, I and D gains added"
    annotation (Placement(transformation(extent={{40,80},{60,100}})));
  Buildings.Controls.OBC.CDL.Continuous.Feedback antWinErr if
       with_I "Error for anti-windup compensation"
    annotation (Placement(transformation(extent={{162,50},{182,70}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain antWinGai(k=1/(k*Ni)) if with_I
    "Gain for anti-windup compensation"
    annotation (
      Placement(transformation(extent={{180,-30},{160,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yResSig(final k=y_reset) if
    with_I
    "Signal for y_reset"
    annotation (Placement(transformation(extent={{-180,-90},{-160,-70}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain divK(final k=1/k) if with_I
    "Division by k for integrator reset"
    annotation (Placement(transformation(extent={{-120,-90},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Continuous.Feedback addRes if with_I
   "Adder for integrator reset"
    annotation (Placement(transformation(extent={{-80,-90},{-60,-70}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant cheYMinMax(
    final k=yMin < yMax)
    "Check for values of yMin and yMax"
    annotation (Placement(transformation(extent={{120,-160},{140,-140}})));
  Buildings.Controls.OBC.CDL.Utilities.Assert assMesYMinMax(message="LimPID: Limits must be yMin < yMax")
    "Assertion on yMin and yMax"
    annotation (Placement(transformation(extent={{160,-160},{180,-140}})));

block Derivative "Block that approximates the derivative of the input"
  parameter Real k(unit="1") = 1 "Gains";
  parameter Modelica.SIunits.Time T(min=1E-60)=0.01
    "Time constant (T>0 required)";
  parameter Real y_start=0 "Initial value of output (= state)"
    annotation(Dialog(group="Initialization"));
  Interfaces.RealInput u "Connector of Real input signal"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Interfaces.RealOutput y "Connector of Real output signal"
    annotation (Placement(transformation(extent={{100,-20},{140,20}})));

  output Real x "State of block";

  protected
  parameter Boolean zeroGain = abs(k) < 1E-17
    "= true, if gain equals to zero";
initial equation
  if zeroGain then
     x = u;
  else
     x = u - T*y_start/k;
  end if;

equation
  der(x) = if zeroGain then 0 else (u - x)/T;
  y = if zeroGain then 0 else (k/T)*(u - x);

annotation (
  defaultComponentName="der",
  Documentation(info="<html>
<p>
This blocks defines the transfer function between the
input <code>u</code> and the output <code>y</code>
as <i>approximated derivative</i>:
</p>
<pre>
             k * s
     y = ------------ * u
            T * s + 1
</pre>
<p>
If <code>k=0</code>, the block reduces to <code>y=0</code>.
</p>
</html>", revisions="<html>
<ul>
<li>
August 7, 2020, by Michael Wetter:<br/>
Moved to protected block in PID controller because the derivative block is no longer part of CDL.
</li>
<li>
April 21, 2020, by Michael Wetter:<br/>
Removed option to not set the initialization method or to set the initial state.
The new implementation only allows to set the initial output, from which
the initial state is computed.
<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1887\">issue 1887</a>.
</li>
<li>
March 2, 2020, by Michael Wetter:<br/>
Changed icon to display dynamically the output value.
</li>
<li>
March 24, 2017, by Jianjun Hu:<br/>
First implementation, based on the implementation of the
Modelica Standard Library.
</li>
</ul>
</html>"), Icon(
    coordinateSystem(preserveAspectRatio=true,
        extent={{-100.0,-100.0},{100.0,100.0}}),
  graphics={
    Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
    Line(points={{-80.0,78.0},{-80.0,-90.0}},
      color={192,192,192}),
  Polygon(lineColor={192,192,192},
    fillColor={192,192,192},
    fillPattern=FillPattern.Solid,
    points={{-80.0,90.0},{-88.0,68.0},{-72.0,68.0},{-80.0,90.0}}),
  Line(points={{-90.0,-80.0},{82.0,-80.0}},
    color={192,192,192}),
  Polygon(lineColor={192,192,192},
    fillColor={192,192,192},
    fillPattern=FillPattern.Solid,
    points={{90.0,-80.0},{68.0,-72.0},{68.0,-88.0},{90.0,-80.0}}),
  Line(origin = {-24.667,-27.333},
    points = {{-55.333,87.333},{-19.333,-40.667},{86.667,-52.667}},
    color = {0,0,127},
    smooth = Smooth.Bezier),
  Text(extent={{-150.0,-150.0},{150.0,-110.0}},
    textString="k=%k"),
  Text(
    extent={{-150,150},{150,110}},
    textString="%name",
    lineColor={0,0,255}),
  Text(
    extent={{226,60},{106,10}},
    lineColor={0,0,0},
    textString=DynamicSelect("", String(y, leftjustified=false, significantDigits=3)))}));
end Derivative;

equation
  connect(trigger, I.trigger)
    annotation (Line(points={{-160,-220},{-160,-140},{-30,-140},{-30,-12}},
      color={255,0,255}));
  connect(u_s, uS_revAct.u) annotation (Line(points={{-240,0},{-212,0},{-212,40},
          {-202,40}},                    color={0,0,127}));
  connect(uS_revAct.y, uSetWp.u) annotation (Line(points={{-178,40},{-170,40},{-170,
          120},{-162,120}},
                          color={0,0,127}));
  connect(u_m, uMea_revAct.u) annotation (Line(points={{0,-220},{0,-160},{-190,
          -160},{-190,-40},{-182,-40}},
                                  color={0,0,127}));
  connect(uS_revAct.y, uSetWd.u) annotation (Line(points={{-178,40},{-170,40},{-170,
          70},{-162,70}}, color={0,0,127}));
  connect(uSetWp.y, errP.u1)
    annotation (Line(points={{-138,120},{-102,120}}, color={0,0,127}));
  connect(errP.u2, uMea_revAct.y) annotation (Line(points={{-90,108},{-90,100},
          {-128,100},{-128,-40},{-158,-40}},color={0,0,127}));
  connect(errD.u1, uSetWd.y) annotation (Line(points={{-102,70},{-138,70}},
                          color={0,0,127}));
  connect(errD.u2, uMea_revAct.y) annotation (Line(points={{-90,58},{-90,48},{
          -128,48},{-128,-40},{-158,-40}},
                      color={0,0,127}));
  connect(D.u,errD. y) annotation (Line(points={{-42,70},{-78,70}},
        color={0,0,127}));
  connect(errI1.u1, uS_revAct.y) annotation (Line(points={{-122,0},{-170,0},{-170,
          40},{-178,40}}, color={0,0,127}));
  connect(errI1.u2, uMea_revAct.y) annotation (Line(points={{-110,-12},{-110,
          -40},{-158,-40}},
                       color={0,0,127}));
  connect(addPD.u1, errP.y)
    annotation (Line(points={{-2,120},{-78,120}}, color={0,0,127}));
  connect(addPID.u1,addPD. y) annotation (Line(points={{38,96},{28,96},{28,114},
          {22,114}}, color={0,0,127}));
  connect(addPID.y, gainPID.u)
    annotation (Line(points={{62,90},{78,90}}, color={0,0,127}));
  connect(lim.u, gainPID.y)
    annotation (Line(points={{118,90},{102,90}}, color={0,0,127}));
  connect(lim.y, y) annotation (Line(points={{142,90},{200,90},{200,0},{240,0}},
        color={0,0,127}));
  connect(antWinErr.y, antWinGai.u) annotation (Line(points={{184,60},{190,60},{
          190,-20},{182,-20}}, color={0,0,127}));
  connect(addPD.u2, Dzero.y) annotation (Line(points={{-2,108},{-10,108},{-10,100},
          {-18,100}}, color={0,0,127}));
  connect(D.y, addPD.u2) annotation (Line(points={{-18,70},{-10,70},{-10,108},{-2,
          108}}, color={0,0,127}));
  connect(addPID.u2, I.y) annotation (Line(points={{38,84},{34,84},{34,0},{-18,0}},
        color={0,0,127}));
  connect(divK.y, addRes.u1)
    annotation (Line(points={{-98,-80},{-82,-80}}, color={0,0,127}));
  connect(addRes.u2, addPD.y) annotation (Line(points={{-70,-92},{-70,-108},{28,
          -108},{28,114},{22,114}}, color={0,0,127}));
  connect(addRes.y, I.y_reset_in) annotation (Line(points={{-58,-80},{-52,-80},
          {-52,-8},{-42,-8}},
               color={0,0,127}));
  connect(divK.u, yResSig.y) annotation (Line(points={{-122,-80},{-158,-80}},
                            color={0,0,127}));
  connect(antWinErr.u1, gainPID.y) annotation (Line(points={{160,60},{110,60},{110,
          90},{102,90}}, color={0,0,127}));
  connect(antWinErr.u2, lim.y) annotation (Line(points={{172,48},{172,40},{150,40},
          {150,90},{142,90}}, color={0,0,127}));
  connect(I.u, errI2.y)
    annotation (Line(points={{-42,0},{-60,0}}, color={0,0,127}));
  connect(errI1.y, errI2.u1)
    annotation (Line(points={{-98,0},{-84,0}}, color={0,0,127}));
  connect(errI2.u2,antWinGai. y)
    annotation (Line(points={{-72,-12},{-72,-20},{158,-20}}, color={0,0,127}));
  connect(controlError.u1, u_s)
    annotation (Line(points={{-202,0},{-240,0}}, color={0,0,127}));
  connect(controlError.u2, u_m) annotation (Line(points={{-190,-12},{-190,-160},
          {0,-160},{0,-220}},                       color={0,0,127}));
  connect(cheYMinMax.y, assMesYMinMax.u)
    annotation (Line(points={{142,-150},{158,-150}}, color={255,0,255}));
  connect(trigger, Izero.u) annotation (Line(points={{-160,-220},{-160,-140},{-22,
          -140}}, color={255,0,255}));
  connect(Izero.y, addPID.u2) annotation (Line(points={{2,-140},{34,-140},{34,84},
          {38,84}}, color={0,0,127}));
annotation (defaultComponentName="conPID",
  Icon(
    coordinateSystem(extent={{-100,-100},{100,100}}),
      graphics={
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-6,-20},{66,-66}},
          lineColor={255,255,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Text(
          visible=(controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.P),
          extent={{-32,-22},{68,-62}},
          lineColor={0,0,0},
          textString="P",
          fillPattern=FillPattern.Solid,
          fillColor={175,175,175}),
        Text(
          visible=(controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PI),
          extent={{-26,-22},{74,-62}},
          lineColor={0,0,0},
          textString="PI",
          fillPattern=FillPattern.Solid,
          fillColor={175,175,175}),
        Text(
          visible=(controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PD),
          extent={{-16,-22},{88,-62}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Solid,
          fillColor={175,175,175},
          textString="P D"),
        Text(
          visible=(controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PID),
          extent={{-14,-22},{86,-62}},
          lineColor={0,0,0},
          textString="PID",
          fillPattern=FillPattern.Solid,
          fillColor={175,175,175}),
        Polygon(
          points={{-80,82},{-88,60},{-72,60},{-80,82}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(points={{-80,68},{-80,-100}},color={192,192,192}),
        Line(points={{-90,-80},{70,-80}}, color={192,192,192}),
        Polygon(
          points={{74,-80},{52,-72},{52,-88},{74,-80}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-150,150},{150,110}},
          textString="%name",
          lineColor={0,0,255}),
        Line(
          points={{-80,-80},{-80,-22}},
          color={0,0,0}),
        Line(
          points={{-80,-22},{6,56}},
          color={0,0,0}),
        Line(
          points={{6,56},{68,56}},
          color={0,0,0}),
        Rectangle(
          extent=DynamicSelect({{100,-100},{84,-100}}, {{100,-100},{84,-100+(y-yMin)/(yMax-yMin)*200}}),
          fillColor={175,175,175},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0})}),
    Diagram(coordinateSystem(extent={{-220,-200},{220,200}})),
Documentation(info="<html>
<p>
PID controller in the standard form
</p>
<p align=\"center\" style=\"font-style:italic;\">
y = k &nbsp; ( e(t) + 1 &frasl; T<sub>i</sub> &nbsp; &int; e(s) ds + T<sub>d</sub> de(t)&frasl;dt ),
</p>
<p>
where
<i>y</i> is the control signal,
<i>e(t) = u<sub>s</sub> - u<sub>m</sub></i> is the control error,
with <i>u<sub>s</sub></i> being the set point and <i>u<sub>m</sub></i> being
the measured quantity,
<i>k</i> is the gain,
<i>T<sub>i</sub></i> is the time constant of the integral term and
<i>T<sub>d</sub></i> is the time constant of the derivative term.
</p>
<p>
Note that the units of <i>k</i> are the inverse of the units of the control error,
while the units of <i>T<sub>i</sub></i> and <i>T<sub>d</sub></i> are seconds.
</p>
<p>
For detailed treatment of integrator anti-windup, set-point weights and output limitation, see
<a href=\"modelica://Modelica.Blocks.Continuous.LimPID\">Modelica.Blocks.Continuous.LimPID</a>.
</p>
<h4>Options</h4>
This controller can be configured as follows.
<h5>P, PI, PD, or PID action</h5>
<p>
Through the parameter <code>controllerType</code>, the controller can be configured
as P, PI, PD or PID controller. The default configuration is PI.
</p>
<h5>Direct or reverse acting</h5>
<p>
Through the parameter <code>reverseActing</code>, the controller can be configured to
be reverse or direct acting.
The above standard form is reverse acting, which is the default configuration.
For a reverse acting controller, for a constant set point,
an increase in measurement signal <code>u_m</code> decreases the control output signal <code>y</code>
(Montgomery and McDowall, 2008).
Thus,
</p>
<ul>
  <li>
  for a heating coil with a two-way valve, leave <code>reverseActing = true</code>, but
  </li>
  <li>
  for a cooling coil with a two-way valve, set <code>reverseActing = false</code>.
  </li>
</ul>
<h5>Reset of the controller output</h5>
<p>
Whenever the value of boolean input signal <code>trigger</code> changes from
<code>false</code> to <code>true</code>, the controller output is reset by setting
<code>y</code> to the value of the parameter <code>y_reset</code>.
</p>
<h4>References</h4>
<p>
R. Montgomery and R. McDowall (2008).
\"Fundamentals of HVAC Control Systems.\"
American Society of Heating Refrigerating and Air-Conditioning Engineers Inc. Atlanta, GA.
</p>
</html>",
revisions="<html>
<ul>
<li>
August 4, 2020, by Jianjun Hu:<br/>
Removed the input <code>y_reset_in</code>.
Refactored to internally implement the derivative block.<br/>
This is for <a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2056\">issue 2056</a>.
</li>
<li>
June 1, 2020, by Michael Wetter:<br/>
Corrected wrong convention of reverse and direct action.<br/>
This is for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1365\">issue 1365</a>.
</li>
<li>
April 23, 2020, by Michael Wetter:<br/>
Changed default parameters for limits <code>yMax</code> from unspecified to <code>1</code>
and <code>yMin</code> from <code>-yMax</code> to <code>0</code>.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1888\">issue 1888</a>.
</li>
<li>
April 7, 2020, by Michael Wetter:<br/>
Reimplemented block using only CDL constructs.
This refactoring removes the no longer use parameters <code>xd_start</code> that was
used to initialize the state of the derivative term. This state is now initialized
based on the requested initial output <code>yd_start</code> which is a new parameter
with a default of <code>0</code>.
Also, removed the parameters <code>y_start</code> and <code>initType</code> because
the initial output of the controller can be set by using <code>xi_start</code>
and <code>yd_start</code>.
This is a non-backward compatible change, made to simplify the controller through
the removal of options that can be realized differently and are hardly ever used.
This refactoring also removes the parameter <code>strict</code> that
was used in the output limiter. The new implementation enforces a strict check by default.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1878\">issue 1878</a>.
</li>
<li>
March 9, 2020, by Michael Wetter:<br/>
Corrected unit declaration for gain <code>k</code>.<br/>
See <a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1821\">issue 1821</a>.
</li>
<li>
March 2, 2020, by Michael Wetter:<br/>
Changed icon to display dynamically the output value.
</li>
<li>
February 25, 2020, by Michael Wetter:<br/>
Changed icon to display the output value.
</li>
<li>
October 19, 2019, by Michael Wetter:<br/>
Disabled homotopy to ensure bounded outputs
by copying the implementation from MSL 3.2.3 and by
hardcoding the implementation for <code>homotopyType=NoHomotopy</code>.<br/>
See <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1221\">issue 1221</a>.
</li>
<li>
November 13, 2017, by Michael Wetter:<br/>
Changed default controller type from PID to PI.
</li>
<li>
November 6, 2017, by Michael Wetter:<br/>
Explicitly declared types and used integrator with reset from CDL.
</li>
<li>
October 22, 2017, by Michael Wetter:<br/>
Added to CDL to have a PI controller with integrator reset.
</li>
<li>
September 29, 2016, by Michael Wetter:<br/>
Refactored model.
</li>
<li>
August 25, 2016, by Michael Wetter:<br/>
Removed parameter <code>limitsAtInit</code> because it was only propagated to
the instance <code>limiter</code>, but this block no longer makes use of this parameter.
This is a non-backward compatible change.<br/>
Revised implemenentation, added comments, made some parameter in the instances final.
</li>
<li>July 18, 2016, by Philipp Mehrfeld:<br/>
Added integrator reset.
This is for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/494\">issue 494</a>.
</li>
<li>
March 15, 2016, by Michael Wetter:<br/>
Changed the default value to <code>strict=true</code> in order to avoid events
when the controller saturates.
This is for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/433\">issue 433</a>.
</li>
<li>
February 24, 2010, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end PIDWithReset;

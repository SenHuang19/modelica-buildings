within Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Generic.EquipmentRotation;
block Multiple "Defines lead-lag or lead-standby equipment rotation for any number of devices or groups of devices
  where the lag load is the same for all lag devices."

  parameter Boolean lag = true
    "true = lead/lag, false = lead/standby";

  parameter Boolean initRoles[nDev] = {if i==1 then true else false for i in 1:nDev}
    "Sets initial roles: true = lead, false = lag or standby"
    annotation (Evaluate=true,Dialog(tab="Advanced", group="Initiation"));

  parameter Integer nDev = 3
    "Total nDevber of devices, such as chillers, isolation valves, CW pumps, or CHW pumps";

  parameter Modelica.SIunits.Time stagingRuntime(displayUnit = "h") = 240 * 60 * 60
    "Staging runtime for each device";

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uLeaSta
    "Lead device status"
    annotation (Placement(transformation(extent={{-260,-20},
            {-220,20}}), iconTransformation(extent={{-140,40},{-100,80}})));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uLagSta if lag
    "Lag device status"
    annotation (Placement(
    transformation(extent={{-260,-120},{-220,-80}}), iconTransformation(
    extent={{-140,-80},{-100,-40}})));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yDevStaSet[nDev]
    "Device status setpoint (index represents the physical device)" annotation
    (Placement(transformation(extent={{240,-50},{260,-30}}), iconTransformation(
          extent={{100,50},{120,70}})));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yDevRol[nDev]
    "Device role: true = lead, false = lag or standby"
    annotation (Placement(transformation(extent={{240,-10},{260,10}}),
        iconTransformation(extent={{100,-70},{120,-50}})));

  Buildings.Controls.OBC.CDL.Continuous.GreaterEqualThreshold greEquThr[nDev](
    final threshold=stagingRuntimes)
    "Stagin runtime hysteresis"
    annotation (Placement(transformation(extent={{-60,50},{-40,70}})));

  Buildings.Controls.OBC.CDL.Logical.Timer tim[nDev](
    final reset=fill(false, nDev))
    "Measures time spent loaded at the current role (lead or lag)"
    annotation (Placement(transformation(extent={{-100,50},{-80,70}})));

protected
  parameter Modelica.SIunits.Time stagingRuntimes[nDev] = fill(stagingRuntime, nDev)
    "Staging runtimes array";

  Buildings.Controls.OBC.CDL.Routing.BooleanReplicator repLag(
    final nout=nDev) if lag
    "Replicates lag signal"
    annotation (Placement(transformation(extent={{-200,-110},{-180,-90}})));

  Buildings.Controls.OBC.CDL.Routing.BooleanReplicator repLead(
    final nout=nDev)
    "Replicates lead signal"
    annotation (Placement(transformation(extent={{-200,-10},{-180,10}})));

  Buildings.Controls.OBC.CDL.Logical.And3 and3[nDev] "Logical and"
    annotation (Placement(transformation(extent={{-20,20},{0,40}})));

  Buildings.Controls.OBC.CDL.Logical.MultiOr mulOr(
    final nu=nDev)
    "Logical or with an array input"
    annotation (Placement(transformation(extent={{20,20},{40,40}})));

  Buildings.Controls.OBC.CDL.Routing.BooleanReplicator booRep(
    final nout=nDev)
    "Converts scalar input into an array output"
    annotation (Placement(transformation(extent={{60,20},{80,40}})));

  Buildings.Controls.OBC.CDL.Logical.Pre pre[nDev](
    final pre_u_start=initRoles)
    "Returns previous timestep value to avoid algebraic loops"
    annotation (Placement(transformation(extent={{120,20},{140,40}})));

  Buildings.Controls.OBC.CDL.Logical.FallingEdge falEdg1[nDev] "Falling edge"
    annotation (Placement(transformation(extent={{0,60},{20,80}})));

  Buildings.Controls.OBC.CDL.Logical.Not not1[nDev]
    "Logical not"
    annotation (Placement(transformation(extent={{-100,20},{-80,40}})));

  Buildings.Controls.OBC.CDL.Continuous.Add add2[nDev](
    final k1=fill(1, nDev),
    final k2=fill(1, nDev))
    "Adder"
    annotation (Placement(transformation(extent={{20,-80},{40,-60}})));

  Buildings.Controls.OBC.CDL.Logical.Edge edg[nDev] "Logical edge"
    annotation (Placement(transformation(extent={{-60,-140},{-40,-120}})));

  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler triSam[nDev]
    "Sample trigger"
    annotation (Placement(transformation(extent={{-40,-100},{-20,-80}})));

  Buildings.Controls.OBC.CDL.Discrete.ZeroOrderHold zerOrdHol[nDev](
    final samplePeriod=fill(1,nDev)) "Zero order hold"
    annotation (Placement(transformation(extent={{80,-60},{100,-40}})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant con1[nDev](
    final k=fill(1, nDev)) "Constant"
    annotation (Placement(transformation(extent={{-40,-60},{-20,-40}})));

  Buildings.Controls.OBC.CDL.Continuous.Modulo mod[nDev]
    "Modulo"
    annotation (Placement(transformation(extent={{100,-120},{120,-100}})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant con2[nDev](
    final k=fill(nDev, nDev)) "Constant"
    annotation (Placement(transformation(extent={{60,-140},{80,-120}})));

  Buildings.Controls.OBC.CDL.Continuous.LessThreshold lesThr[nDev](
    final threshold=fill(0.5, nDev))
    "Identifies zero outputs of the modulo operation"
    annotation (Placement(transformation(extent={{140,-120},{160,-100}})));

  Buildings.Controls.OBC.CDL.Continuous.Add add1[nDev](
    final k1=fill(1, nDev),
    final k2=fill(1, nDev))
    "Logical and"
    annotation (Placement(transformation(extent={{60,-100},{80,-80}})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant con3[nDev](
    final k=linspace(nDev - 1, 0, nDev)) "Constant"
    annotation (Placement(transformation(extent={{20,-120},{40,-100}})));

  Buildings.Controls.OBC.CDL.Logical.LogicalSwitch logSwi[nDev]
    annotation (Placement(transformation(extent={{-140,-40},{-120,-20}})));

  Buildings.Controls.OBC.CDL.Logical.Sources.Constant staSta[nDev](
    final k=fill(false, nDev)) if not lag
    "Standby status"
    annotation (Placement(transformation(extent={{-200,-70},{-180,-50}})));
equation
  connect(greEquThr.y, and3.u1) annotation (Line(points={{-38,60},{-30,60},{-30,
          38},{-22,38}},
                       color={255,0,255}));
  connect(mulOr.y, booRep.u) annotation (Line(points={{42,30},{58,30}},
                    color={255,0,255}));
  connect(not1.y,and3. u2)
    annotation (Line(points={{-78,30},{-22,30}}, color={255,0,255}));
  connect(tim.u0, falEdg1.y) annotation (Line(points={{-102,52},{-120,52},{-120,
          100},{40,100},{40,70},{22,70}},
                                        color={255,0,255}));
  connect(pre.y, and3.u3) annotation (Line(points={{142,30},{160,30},{160,10},{
          -30,10},{-30,22},{-22,22}},          color={255,0,255}));
  connect(tim.y, greEquThr.u)
    annotation (Line(points={{-78,60},{-62,60}}, color={0,0,127}));
  connect(pre.y, falEdg1.u) annotation (Line(points={{142,30},{160,30},{160,90},
          {-20,90},{-20,70},{-2,70}},     color={255,0,255}));
  connect(edg.y, triSam.trigger) annotation (Line(points={{-38,-130},{-30,-130},
          {-30,-101.8}},
                    color={255,0,255}));
  connect(triSam.y, add2.u2) annotation (Line(points={{-18,-90},{0,-90},{0,-76},
          {18,-76}},  color={0,0,127}));
  connect(add2.y, zerOrdHol.u) annotation (Line(points={{42,-70},{60,-70},{60,
          -50},{78,-50}},   color={0,0,127}));
  connect(zerOrdHol.y, triSam.u) annotation (Line(points={{102,-50},{112,-50},{
          112,-20},{-60,-20},{-60,-90},{-42,-90}},     color={0,0,127}));
  connect(add2.u1, con1.y) annotation (Line(points={{18,-64},{0,-64},{0,-50},{
          -18,-50}},  color={0,0,127}));
  connect(con2.y, mod.u2) annotation (Line(points={{82,-130},{88,-130},{88,-116},
          {98,-116}},  color={0,0,127}));
  connect(mod.y, lesThr.u) annotation (Line(points={{122,-110},{129.5,-110},{
          129.5,-110},{138,-110}},  color={0,0,127}));
  connect(add2.y, add1.u1) annotation (Line(points={{42,-70},{50,-70},{50,-84},
          {58,-84}},  color={0,0,127}));
  connect(add1.u2, con3.y) annotation (Line(points={{58,-96},{50,-96},{50,-110},
          {42,-110}}, color={0,0,127}));
  connect(add1.y, mod.u1) annotation (Line(points={{82,-90},{88,-90},{88,-104},
          {98,-104}},  color={0,0,127}));
  connect(booRep.y, edg.u) annotation (Line(points={{82,30},{92,30},{92,0},{-80,
          0},{-80,-130},{-62,-130}},   color={255,0,255}));
  connect(lesThr.y, pre.u) annotation (Line(points={{162,-110},{180,-110},{180,
          0},{100,0},{100,30},{118,30}},  color={255,0,255}));
  connect(lesThr.y, yDevRol) annotation (Line(points={{162,-110},{200,-110},{
          200,0},{250,0}},                 color={255,0,255}));
  connect(and3.y, mulOr.u) annotation (Line(points={{2,30},{18,30}},
                      color={255,0,255}));
  connect(logSwi.y, tim.u) annotation (Line(points={{-118,-30},{-110,-30},{-110,
          60},{-102,60}}, color={255,0,255}));
  connect(logSwi.y, not1.u) annotation (Line(points={{-118,-30},{-110,-30},{
          -110,30},{-102,30}}, color={255,0,255}));
  connect(uLagSta, repLag.u)
    annotation (Line(points={{-240,-100},{-202,-100}}, color={255,0,255}));
  connect(uLeaSta, repLead.u)
    annotation (Line(points={{-240,0},{-202,0}}, color={255,0,255}));
  connect(logSwi.u1, repLead.y) annotation (Line(points={{-142,-22},{-150,-22},
          {-150,0},{-178,0}}, color={255,0,255}));
  connect(logSwi.u3, repLag.y) annotation (Line(points={{-142,-38},{-160,-38},{
          -160,-100},{-178,-100}}, color={255,0,255}));
  connect(pre.y, logSwi.u2) annotation (Line(points={{142,30},{160,30},{160,120},
          {-160,120},{-160,-30},{-142,-30}}, color={255,0,255}));
  connect(logSwi.y, yDevStaSet) annotation (Line(points={{-118,-30},{-70,-30},{
          -70,-10},{220,-10},{220,-40},{250,-40}}, color={255,0,255}));
  connect(staSta.y, logSwi.u3) annotation (Line(points={{-178,-60},{-160,-60},{
          -160,-38},{-142,-38}},
                            color={255,0,255}));
  annotation (Diagram(coordinateSystem(extent={{-220,-160},{240,160}})),
      defaultComponentName="equRot",
    Icon(graphics={
        Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Ellipse(
          origin={-26.6667,38.6207},
          lineColor={128,128,128},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          extent={{-53.3333,1.37927},{-13.3329,41.3792}}),
        Ellipse(
          origin={93.3333,-81.3793},
          lineColor={128,128,128},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          extent={{-53.3333,1.37927},{-13.3329,41.3792}}),
        Ellipse(
          origin={-26.6667,-81.3793},
          lineColor={128,128,128},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-53.3333,1.37927},{-13.3329,41.3792}}),
        Ellipse(
          origin={93.333,38.6207},
          lineColor={128,128,128},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-53.3333,1.37927},{-13.3329,41.3792}}),
        Line(points={{-40,60},{0,60},{0,-60},{40,-60}}, color={128,128,128}),
        Line(points={{-40,-60},{0,-60},{0,60},{40,60}}, color={128,128,128}),
        Text(
          extent={{-120,146},{100,108}},
          lineColor={0,0,255},
          textString="%name"),
        Ellipse(
          origin={-26.667,-19.3793},
          lineColor={128,128,128},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          extent={{-53.3333,1.37927},{-13.3329,41.3792}}),
        Ellipse(
          origin={93.333,-19.3793},
          lineColor={128,128,128},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          extent={{-53.3333,1.37927},{-13.3329,41.3792}})}),
  Documentation(info="<html>
<p>
This block rotates equipment, such as chillers, pumps or valves, in order 
to ensure equal wear and tear. It can be used for lead/lag and 
lead/standby operation, as specified in &quot;ASHRAE Fundamentals of Chilled Water Plant Design and Control SDL&quot;, 
Chapter 7, App B, 1.01, A.4.  The input vector <code>uDevRol<\code> indicates the lead/lag (or lead/standby) status
of the devices. Default initial lead role is assigned to the device associated
with the first index in the input vector. The block measures the <code>stagingRuntime<\code> 
for each device and switches the lead role to the next higher index
as its <code>stagingRuntime<\code> expires. It can be used for any nDevber of devices <code>nDev<\code>.
</p>
</html>", revisions="<html>
<ul>
<li>
September 20, by Milica Grahovac:<br/>
First implementation.
</li>
</ul>

</html>"));
end Multiple;
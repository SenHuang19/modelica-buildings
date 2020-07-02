within Buildings.Controls.OBC.ASHRAE.PrimarySystem.BoilerPlant.Staging.Processes.Validation;
model UpWithOnOff
  "Validate sequence of staging up process which does require chiller OFF"

  Buildings.Controls.OBC.ASHRAE.PrimarySystem.BoilerPlant.Staging.Processes.Up upProCon(
    final nChi=2,
    final totSta=4,
    final have_PonyChiller=true,
    final chaChiWatIsoTim=300,
    final staVec={0,0.5,1,2},
    final desConWatPumSpe={0,0.5,0.75,0.6},
    final desConWatPumNum={0,1,1,2},
    final byPasSetTim=300,
    final minFloSet={0.5,1},
    final maxFloSet={1,1.5})
    "Stage up process when does not require chiller off"
    annotation (Placement(transformation(extent={{20,80},{40,120}})));

protected
  Buildings.Controls.OBC.CDL.Continuous.Sources.Ramp chiWatFlo(
    final height=5/3 - 0.5,
    final duration=300,
    final offset=0.5,
    final startTime=500) "Chilled water flow rate"
    annotation (Placement(transformation(extent={{-200,-70},{-180,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Pulse booPul(
    final width=0.075,
    final period=2000) "Boolean pulse"
    annotation (Placement(transformation(extent={{-200,110},{-180,130}})));
  Buildings.Controls.OBC.CDL.Logical.Not staUp "Stage up command"
    annotation (Placement(transformation(extent={{-160,110},{-140,130}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant fulLoa(final k=1000)
    "Full load"
    annotation (Placement(transformation(extent={{-200,10},{-180,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zerLoa(final k=0)
    "Zero load"
    annotation (Placement(transformation(extent={{-200,-30},{-180,-10}})));
  Buildings.Controls.OBC.CDL.Logical.Pre chiOneSta(final pre_u_start=true)
    "Break algebraic loop"
    annotation (Placement(transformation(extent={{80,60},{100,80}})));
  Buildings.Controls.OBC.CDL.Logical.Switch loaOne "Chiller load one"
    annotation (Placement(transformation(extent={{-120,10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Discrete.ZeroOrderHold zerOrdHol[2](
    final samplePeriod=fill(10, 2))
    "Output the input signal with a zero order hold"
    annotation (Placement(transformation(extent={{80,-190},{100,-170}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant wseSta(final k=false)
    "Waterside economizer status"
    annotation (Placement(transformation(extent={{-200,-190},{-180,-170}})));
  Buildings.Controls.OBC.CDL.Discrete.ZeroOrderHold conPumSpeSet(
    final samplePeriod=10) "Design condenser water pump speed setpoint"
    annotation (Placement(transformation(extent={{80,-30},{100,-10}})));
  Buildings.Controls.OBC.CDL.Discrete.ZeroOrderHold conPumSpe(
    final samplePeriod=20) "Condenser water pump speed"
    annotation (Placement(transformation(extent={{80,-70},{100,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Switch loaTwo "Chiller load two"
    annotation (Placement(transformation(extent={{-120,-30},{-100,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer3[2](
    final k=fill(0,2)) "Constant zero"
    annotation (Placement(transformation(extent={{80,100},{100,120}})));
  Buildings.Controls.OBC.CDL.Discrete.ZeroOrderHold chiTwoDem(
    final samplePeriod=10) "Chiller two limited demand"
    annotation (Placement(transformation(extent={{80,130},{100,150}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant chiLoa3(final k=1000)
    "Chiller load"
    annotation (Placement(transformation(extent={{80,160},{100,180}})));
  Buildings.Controls.OBC.CDL.Logical.Switch chiLoa[2] "Limited chiller load"
    annotation (Placement(transformation(extent={{140,130},{160,150}})));
  Buildings.Controls.OBC.CDL.Discrete.ZeroOrderHold chiTwoDem1(
    final samplePeriod=10) "Limited chiller two demand"
    annotation (Placement(transformation(extent={{180,130},{200,150}})));
  Buildings.Controls.OBC.CDL.Logical.Pre chiTwoSta(
    final pre_u_start=false) "Chiller two status"
    annotation (Placement(transformation(extent={{80,20},{100,40}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zerOpe(
    final k=0) "Closed isolation valve"
    annotation (Placement(transformation(extent={{-200,-270},{-180,-250}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant fulOpe(
    final k=1) "Full open isolation valve"
    annotation (Placement(transformation(extent={{-200,-230},{-180,-210}})));
  Buildings.Controls.OBC.CDL.Logical.Switch IsoValOne "Logical switch"
    annotation (Placement(transformation(extent={{-120,-230},{-100,-210}})));
  Buildings.Controls.OBC.CDL.Logical.Switch IsoValTwo "Logical switch"
    annotation (Placement(transformation(extent={{-120,-270},{-100,-250}})));
  Buildings.Controls.OBC.CDL.Logical.Pre chiOneHea(final pre_u_start=true)
    "Chiller one head pressure control"
    annotation (Placement(transformation(extent={{80,-110},{100,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Pre chiTwoHea(final pre_u_start=false)
    "Chiller two head pressure control"
    annotation (Placement(transformation(extent={{80,-150},{100,-130}})));
  Buildings.Controls.OBC.CDL.Discrete.ZeroOrderHold zerOrdHol3(
    final samplePeriod=20)
    "Output the input signal with a zero order hold"
    annotation (Placement(transformation(extent={{80,-230},{100,-210}})));
  Buildings.Controls.OBC.CDL.Logical.Switch chiWatFlo1 "Chilled water flow rate"
    annotation (Placement(transformation(extent={{-120,-70},{-100,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Pre  chiOneHea1(final pre_u_start=false)
    "Chiller one head pressure control"
    annotation (Placement(transformation(extent={{0,-30},{20,-10}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant staOneChi[2](
    final k={true,false})
    "Vector of chillers status setpoint at stage one"
    annotation (Placement(transformation(extent={{-200,70},{-180,90}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant staTwoChi[2](
    final k={false,true})
    "Vector of chillers status setpoint at stage two"
    annotation (Placement(transformation(extent={{-200,150},{-180,170}})));
  Buildings.Controls.OBC.CDL.Routing.BooleanReplicator booRep(final nout=2)
    "Replicate boolean input"
    annotation (Placement(transformation(extent={{-120,110},{-100,130}})));
  Buildings.Controls.OBC.CDL.Logical.LogicalSwitch chiSet[2]
    "Chiller status setpoint"
    annotation (Placement(transformation(extent={{-80,130},{-60,150}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant dowSta(final k=1)
    "Stage one"
    annotation (Placement(transformation(extent={{-200,190},{-180,210}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant upSta(final k=2)
    "Stage two"
    annotation (Placement(transformation(extent={{-200,220},{-180,240}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swi "Logical switch"
    annotation (Placement(transformation(extent={{-120,200},{-100,220}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger staSet
    "Stage setpoint index"
    annotation (Placement(transformation(extent={{-80,200},{-60,220}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant staOne(final k=1) "Stage one"
    annotation (Placement(transformation(extent={{-200,-150},{-180,-130}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant staTwo(final k=2)
    "Stage two"
    annotation (Placement(transformation(extent={{-200,-110},{-180,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Switch chiSta "Current chiller stage"
    annotation (Placement(transformation(extent={{-120,-130},{-100,-110}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger sta "Current chiller stage"
    annotation (Placement(transformation(extent={{-80,-130},{-60,-110}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant  fal(final k=false)
    "Logical false"
    annotation (Placement(transformation(extent={{140,170},{160,190}})));
  Buildings.Controls.OBC.CDL.Logical.FallingEdge  falEdg
    "Check if the up process has ended"
    annotation (Placement(transformation(extent={{80,190},{100,210}})));
  Buildings.Controls.OBC.CDL.Logical.Latch  lat
    "True when it is not in process"
    annotation (Placement(transformation(extent={{180,190},{200,210}})));

equation
  connect(booPul.y, staUp.u)
    annotation (Line(points={{-178,120},{-162,120}}, color={255,0,255}));
  connect(fulLoa.y, loaOne.u3) annotation (Line(points={{-178,20},{-160,20},{-160,
          12},{-122,12}}, color={0,0,127}));
  connect(zerLoa.y, loaTwo.u3) annotation (Line(points={{-178,-20},{-160,-20},{-160,
          -28},{-122,-28}}, color={0,0,127}));
  connect(staUp.y, loaOne.u2) annotation (Line(points={{-138,120},{-130,120},{-130,
          20},{-122,20}}, color={255,0,255}));
  connect(staUp.y, loaTwo.u2) annotation (Line(points={{-138,120},{-130,120},{-130,
          -20},{-122,-20}}, color={255,0,255}));
  connect(upProCon.yChi[1], chiOneSta.u) annotation (Line(points={{42,80},{60,80},
          {60,70},{78,70}},   color={255,0,255}));
  connect(upProCon.yChi[2], chiTwoSta.u) annotation (Line(points={{42,82},{58,82},
          {58,30},{78,30}}, color={255,0,255}));
  connect(chiOneSta.y, chiLoa[1].u2) annotation (Line(points={{102,70},{130,70},
          {130,140},{138,140}},      color={255,0,255}));
  connect(chiTwoSta.y, chiLoa[2].u2) annotation (Line(points={{102,30},{132,30},
          {132,140},{138,140}}, color={255,0,255}));
  connect(upProCon.yChiDem[2], chiTwoDem.u) annotation (Line(points={{42,116},{60,
          116},{60,140},{78,140}}, color={0,0,127}));
  connect(chiTwoDem.y, chiLoa[2].u1) annotation (Line(points={{102,140},{120,140},
          {120,148},{138,148}},      color={0,0,127}));
  connect(chiLoa3.y, chiLoa[1].u1) annotation (Line(points={{102,170},{120,170},
          {120,148},{138,148}}, color={0,0,127}));
  connect(zer3.y, chiLoa.u3) annotation (Line(points={{102,110},{120,110},{120,132},
          {138,132}},      color={0,0,127}));
  connect(chiLoa[2].y, chiTwoDem1.u)
    annotation (Line(points={{162,140},{178,140}}, color={0,0,127}));
  connect(chiLoa[1].y, loaOne.u1) annotation (Line(points={{162,140},{170,140},{
          170,46},{-140,46},{-140,28},{-122,28}},  color={0,0,127}));
  connect(chiTwoDem1.y, loaTwo.u1) annotation (Line(points={{202,140},{210,140},
          {210,0},{-140,0},{-140,-12},{-122,-12}}, color={0,0,127}));
  connect(loaOne.y, upProCon.uChiLoa[1]) annotation (Line(points={{-98,20},{-60,
          20},{-60,111},{18,111}}, color={0,0,127}));
  connect(loaTwo.y, upProCon.uChiLoa[2]) annotation (Line(points={{-98,-20},{-58,
          -20},{-58,113},{18,113}},color={0,0,127}));
  connect(chiOneSta.y, upProCon.uChi[1]) annotation (Line(points={{102,70},{130,
          70},{130,50},{-56,50},{-56,109},{18,109}},  color={255,0,255}));
  connect(chiTwoSta.y, upProCon.uChi[2]) annotation (Line(points={{102,30},{132,
          30},{132,10},{-54,10},{-54,111},{18,111}}, color={255,0,255}));
  connect(zerOpe.y, IsoValTwo.u3) annotation (Line(points={{-178,-260},{-160,-260},
          {-160,-268},{-122,-268}}, color={0,0,127}));
  connect(fulOpe.y, IsoValOne.u3) annotation (Line(points={{-178,-220},{-160,-220},
          {-160,-228},{-122,-228}}, color={0,0,127}));
  connect(staUp.y, IsoValOne.u2) annotation (Line(points={{-138,120},{-130,120},
          {-130,-220},{-122,-220}}, color={255,0,255}));
  connect(staUp.y, IsoValTwo.u2) annotation (Line(points={{-138,120},{-130,120},
          {-130,-260},{-122,-260}}, color={255,0,255}));
  connect(upProCon.yChiWatIsoVal, zerOrdHol.u) annotation (Line(points={{42,86},
          {56,86},{56,-180},{78,-180}},  color={0,0,127}));
  connect(zerOrdHol[1].y, IsoValOne.u1) annotation (Line(points={{102,-180},{120,
          -180},{120,-200},{-140,-200},{-140,-212},{-122,-212}}, color={0,0,127}));
  connect(zerOrdHol[2].y, IsoValTwo.u1) annotation (Line(points={{102,-180},{120,
          -180},{120,-200},{-140,-200},{-140,-252},{-122,-252}}, color={0,0,127}));
  connect(chiOneSta.y, upProCon.uChiConIsoVal[1]) annotation (Line(points={{102,70},
          {130,70},{130,50},{-50,50},{-50,104},{18,104}},       color={255,0,255}));
  connect(chiTwoSta.y, upProCon.uChiConIsoVal[2]) annotation (Line(points={{102,30},
          {132,30},{132,10},{-48,10},{-48,106},{18,106}},     color={255,0,255}));
  connect(chiOneSta.y, upProCon.uConWatReq[1]) annotation (Line(points={{102,70},
          {130,70},{130,50},{-44,50},{-44,97},{18,97}},    color={255,0,255}));
  connect(chiTwoSta.y, upProCon.uConWatReq[2]) annotation (Line(points={{102,30},
          {132,30},{132,10},{-42,10},{-42,99},{18,99}},   color={255,0,255}));
  connect(wseSta.y, upProCon.uWSE) annotation (Line(points={{-178,-180},{-40,-180},
          {-40,95},{18,95}},   color={255,0,255}));
  connect(upProCon.yDesConWatPumSpe, conPumSpeSet.u) annotation (Line(points={{42,99},
          {54,99},{54,-20},{78,-20}},        color={0,0,127}));
  connect(conPumSpeSet.y, conPumSpe.u) annotation (Line(points={{102,-20},{120,-20},
          {120,-40},{60,-40},{60,-60},{78,-60}}, color={0,0,127}));
  connect(conPumSpeSet.y, upProCon.uConWatPumSpeSet) annotation (Line(points={{102,-20},
          {120,-20},{120,-40},{-38,-40},{-38,92},{18,92}},      color={0,0,127}));
  connect(conPumSpe.y, upProCon.uConWatPumSpe) annotation (Line(points={{102,-60},
          {120,-60},{120,-80},{-36,-80},{-36,89},{18,89}},   color={0,0,127}));
  connect(upProCon.yChiHeaCon[1], chiOneHea.u) annotation (Line(points={{42,90},
          {52,90},{52,-100},{78,-100}},color={255,0,255}));
  connect(upProCon.yChiHeaCon[2], chiTwoHea.u) annotation (Line(points={{42,92},
          {50,92},{50,-140},{78,-140}},  color={255,0,255}));
  connect(chiOneHea.y, upProCon.uChiHeaCon[1]) annotation (Line(points={{102,-100},
          {120,-100},{120,-120},{-34,-120},{-34,85},{18,85}},color={255,0,255}));
  connect(chiTwoHea.y, upProCon.uChiHeaCon[2]) annotation (Line(points={{102,-140},
          {120,-140},{120,-160},{-32,-160},{-32,87},{18,87}},   color={255,0,255}));
  connect(IsoValOne.y, upProCon.uChiWatIsoVal[1]) annotation (Line(points={{-98,
          -220},{-30,-220},{-30,82},{18,82}},   color={0,0,127}));
  connect(IsoValTwo.y, upProCon.uChiWatIsoVal[2]) annotation (Line(points={{-98,
          -260},{-28,-260},{-28,84},{18,84}},   color={0,0,127}));
  connect(chiOneSta.y, upProCon.uChiWatReq[1]) annotation (Line(points={{102,70},
          {130,70},{130,50},{-26,50},{-26,80},{18,80}},    color={255,0,255}));
  connect(chiTwoSta.y, upProCon.uChiWatReq[2]) annotation (Line(points={{102,30},
          {132,30},{132,10},{-24,10},{-24,82},{18,82}},   color={255,0,255}));
  connect(upProCon.yChiWatMinFloSet, zerOrdHol3.u) annotation (Line(points={{42,111},
          {48,111},{48,-220},{78,-220}},      color={0,0,127}));
  connect(chiWatFlo.y, chiWatFlo1.u3) annotation (Line(points={{-178,-60},{-160,
          -60},{-160,-68},{-122,-68}}, color={0,0,127}));
  connect(zerOrdHol3.y, chiWatFlo1.u1) annotation (Line(points={{102,-220},{120,
          -220},{120,-240},{-90,-240},{-90,-40},{-140,-40},{-140,-52},{-122,-52}},
        color={0,0,127}));
  connect(chiWatFlo1.y, upProCon.VChiWat_flow) annotation (Line(points={{-98,-60},
          {-52,-60},{-52,107.6},{18,107.6}}, color={0,0,127}));
  connect(upProCon.yTowStaUp, chiOneHea1.u) annotation (Line(points={{42,107},{46,
          107},{46,20},{-20,20},{-20,-20},{-2,-20}}, color={255,0,255}));
  connect(chiOneHea1.y, chiWatFlo1.u2) annotation (Line(points={{22,-20},{40,-20},
          {40,-34},{-150,-34},{-150,-60},{-122,-60}}, color={255,0,255}));
  connect(upSta.y, swi.u1) annotation (Line(points={{-178,230},{-160,230},{-160,
          218},{-122,218}}, color={0,0,127}));
  connect(dowSta.y, swi.u3) annotation (Line(points={{-178,200},{-160,200},{-160,
          202},{-122,202}}, color={0,0,127}));
  connect(swi.y, staSet.u)
    annotation (Line(points={{-98,210},{-82,210}}, color={0,0,127}));
  connect(booRep.y, chiSet.u2) annotation (Line(points={{-98,120},{-92,120},{-92,
          140},{-82,140}}, color={255,0,255}));
  connect(staUp.y, booRep.u)
    annotation (Line(points={{-138,120},{-122,120}}, color={255,0,255}));
  connect(staOneChi.y, chiSet.u3) annotation (Line(points={{-178,80},{-88,80},{-88,
          132},{-82,132}},      color={255,0,255}));
  connect(staTwoChi.y, chiSet.u1) annotation (Line(points={{-178,160},{-90,160},
          {-90,148},{-82,148}}, color={255,0,255}));
  connect(staUp.y, swi.u2) annotation (Line(points={{-138,120},{-130,120},{-130,
          210},{-122,210}}, color={255,0,255}));
  connect(staSet.y, upProCon.uStaSet) annotation (Line(points={{-58,210},{0,210},
          {0,119},{18,119}}, color={255,127,0}));
  connect(chiSet.y, upProCon.uChiSet) annotation (Line(points={{-58,140},{-4,140},
          {-4,116},{18,116}}, color={255,0,255}));
  connect(staTwo.y, chiSta.u1) annotation (Line(points={{-178,-100},{-160,-100},
          {-160,-112},{-122,-112}}, color={0,0,127}));
  connect(staOne.y, chiSta.u3) annotation (Line(points={{-178,-140},{-160,-140},
          {-160,-128},{-122,-128}}, color={0,0,127}));
  connect(chiSta.y, sta.u)
    annotation (Line(points={{-98,-120},{-82,-120}}, color={0,0,127}));
  connect(sta.y, upProCon.uChiSta) annotation (Line(points={{-58,-120},{-46,-120},
          {-46,102},{18,102}}, color={255,127,0}));
  connect(upProCon.yStaPro, falEdg.u) annotation (Line(points={{42,119},{56,119},
          {56,200},{78,200}}, color={255,0,255}));
  connect(falEdg.y, lat.u)
    annotation (Line(points={{102,200},{178,200}}, color={255,0,255}));
  connect(fal.y, lat.clr) annotation (Line(points={{162,180},{170,180},{170,194},
          {178,194}}, color={255,0,255}));
  connect(lat.y, chiSta.u2) annotation (Line(points={{202,200},{214,200},{214,-84},
          {-140,-84},{-140,-120},{-122,-120}}, color={255,0,255}));

annotation (
 experiment(StopTime=2000, Tolerance=1e-06),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Controls/OBC/ASHRAE/PrimarySystem/ChillerPlant/Staging/Processes/Validation/UpWithOnOff.mos"
    "Simulate and plot"),
  Documentation(info="<html>
<p>
This example validates
<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Up\">
Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Up</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
October 14, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"),
Icon(coordinateSystem(extent={{-100,-100},{100,100}}),
     graphics={
        Ellipse(lineColor = {75,138,73},
                fillColor={255,255,255},
                fillPattern = FillPattern.Solid,
                extent = {{-100,-100},{100,100}}),
        Polygon(lineColor = {0,0,255},
                fillColor = {75,138,73},
                pattern = LinePattern.None,
                fillPattern = FillPattern.Solid,
                points = {{-36,60},{64,0},{-36,-60},{-36,60}})}),Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-220,-300},{220,300}}),
        graphics={
        Text(
          extent={{-208,294},{-160,286}},
          lineColor={0,0,127},
          textString="Stage up:"),
        Text(
          extent={{-196,280},{-50,272}},
          lineColor={0,0,127},
          textString="from stage 1 which has small chiller one been enabled, "),
        Text(
          extent={{-196,268},{-70,254}},
          lineColor={0,0,127},
          textString="to stage 2 which has large chiller 2 been enabled.")}));
end UpWithOnOff;
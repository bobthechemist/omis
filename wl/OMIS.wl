(* 
  ::OMIS:: 
  Wolfram language package for developing an OMIS user interface.
*)
BeginPackage["OMIS`"];

$arduino = Null;
$pauseLength = 0.000; (* May be needed to slow communication *)
$validCommands = {}; (* Do I want this here, which duplicates Arduino code? *)
$arduinoMessage = Association[{Now -> "Not connected"}];
(* TODO: Add Log export button *)
$listenTask = Null;

listen[] := Module[{temp},
	If[$arduino =!= Null,
		Pause[$pauseLength];
    (* Read the ASCII characters from the serial buffer, delete linefeeds and convert to a string *)
		temp = FromCharacterCode /@ 
      DeleteCases[DeviceReadBuffer[$arduino],10] // StringJoin;
    If[temp =!= "", $arduinoMessage[Now] = StringDrop[temp,-1]];
  ];
]

connect[port_String]:=Module[{},
	$arduino = DeviceOpen["Serial",{port, "BaudRate"-> 115200}];
	$arduinoMessage[Now] = "Connected. Press reset on Arduino.";
	$listenTask = RunScheduledTask[listen[]];
]	

disconnect[]:=Module[{},
	$arduinoMessage[Now] = "Closing...";
	If[$listenTask =!= Null, RemoveScheduledTask@$listenTask];
	$listenTask = Null;
	If[$arduino =!= Null, DeviceClose[$arduino]];
	$arduino = Null;
	$arduinoMessage[Now] = "Not Connected";

]

sendCommand[command_String]:=Module[{},
	If[$arduino =!= Null,
		(* Make sure there is sufficient time between commands *)
		Pause[$pauseLength];
		DeviceWrite[$arduino, command <> "\n"];
		listen[];
	]
]	
				
simpleInterface[] := DynamicModule[{whichPump="0", op="tu", value="1", size = 300},Column[{
	Row[{
		Button["Connect",connect["COM3"],Method->"Queued"],
		Button["Disconnect",disconnect[],Method->"Queued"]
	}],
	Panel[
		Column[{
			Row[{
				"Pump: \t",
				RadioButtonBar[Dynamic@whichPump,{"0"->"#1", "1"->"#2"}]
			}],
			Row[{
				"Operation: ",
				PopupMenu[Dynamic@op,{"ss"->"Set RPMs", "mv"->"Take Steps", "tu"->"Full Turns", "sf"->"Flow Rate", "de"->"Deliver uL"}],
				InputField[Dynamic[value],String,ContinuousAction->True,FieldSize->{5,1}]
			}],
			OpenerView[{"Commands",Column[{
				Dynamic["sp "<> whichPump],
				Dynamic[op <> " " <> value]
			}]}],
			Button["Execute",(
				sendCommand["sp " <> whichPump];
				sendCommand[op <> " " <> value];
			)]
		},Alignment->Left],
	ImageSize->{size,Automatic}],
  Dynamic@With[{content = Column@Values@$arduinoMessage},
    Pane[content,ImageSize->{size,100},
      (* scroll position hack to deal with problems in this https://mathematica.stackexchange.com/a/1747/7167 *)
      ScrollPosition -> {0, If[Last@ImageDimensions@Rasterize@content < 100, 0, 10^15]},
      Scrollbars -> {False, True},
      AppearanceElements -> None]
  ]
}]]

(* ::HOWITWORKS::
  Using the total volume flow rate, the lowest desired flow rate, number of ratios and time at each ratio,
  create a sequence of OMIS commands that will adjust the motor speeds and deliver the correct amount of fluid.
  Command sequences are riffled with pauses to avoid overloading the OMIS step buffers.  The additional delay
  could be used to allow for some measurement to be made under "stopped flow" conditions.
*)

(* TODO: Add Option to manually change communicationDelay, determine how to deal with errors, such as 
  flow rates that would exceed the boundaries of the motor. Possible have a "sf check" routine that looks
  for the OMIS error when cycling through the speeds.
*)
continuousVariation[totalFlowRate_, minFlowRate_, numRatios_, time_] :=
  Module[{communicationDelay = 0.5, commandSequence},
  commandSequence = Map[ {
      "sp 0", "sf " <> ToString[#1], "de " <> ToString[#1 time/60], 
      "sp 1", "sf " <> ToString[totalFlowRate - #1], 
      "de " <> ToString[(totalFlowRate - #1) time/60]
      } &, 
    Range[minFlowRate, 
      totalFlowRate - minFlowRate, (totalFlowRate - minFlowRate)/
       numRatios] // N
    ];
  $arduinoMessage[Now] = Style["Starting sequence", Blue];
  Table[{sendCommand /@ i, Pause[time + communicationDelay]}, {i, 
    commandSequence}];
  $arduinoMessage[Now] = Style["Sequence complete", Blue];
]

EndPackage[];

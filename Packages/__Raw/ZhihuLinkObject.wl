(* ::Package:: *)
(* ::Title:: *)
(*ZhihuLinkObject*)
(* ::Subchapter:: *)
(*程序包介绍*)
(* ::Text:: *)
(*Mathematica Package*)
(*Created by Mathematica Plugin for IntelliJ IDEA*)
(**)
(* ::Text:: *)
(*Creation Date: 2018-03-12*)
(*Copyright: Mozilla Public License Version 2.0*)
(* ::Program:: *)
(*1.软件产品再发布时包含一份原始许可声明和版权声明。*)
(*2.提供快速的专利授权。*)
(*3.不得使用其原始商标。*)
(*4.如果修改了源代码，包含一份代码修改说明。*)
(* ::Section:: *)
(*函数说明*)
BeginPackage["ZhihuLinkObject`"];
ZhihuLinkObject::usage="";
ZhihuConnect::usage="";
$ZhihuLinkIcon::usage="";
(* ::Section:: *)
(*程序包正体*)
$ZhihuLinkIcon=Import[DirectoryName@FindFile["ZhihuLink`ZhihuLinkLoader`"]<>"ZhihuLinkLogo.png"];
Begin["`Private`"];
(* ::Subsection::Closed:: *)
(*主体代码*)
(* ::Subsubsection:: *)
(*ZhihuLinkUserObject*)
CookiesGetMe[cookie_,auth_]:=Block[
	{req=HTTPRequest[
		"https://api.zhihu.com/people/self",
		<|
			"Headers"-><|"authorization"->auth|>,
			"Cookies"->cookie,
			"Query"->{"include"->"gender,voteup_count,follower_count,account_status"}
		|>]},
	GeneralUtilities`ToAssociations@URLExecute[req,Authentication->None,Interactive->False]
]//Quiet;
ZhihuConnect[cookie_String]:=Block[
	{zc0,auth,me,img},
	zc0=Select[StringSplit[StringDelete[cookie," "],";"],StringTake[#,5]=="z_c0="&];
	auth="Bearer "<>StringTake[First@zc0,6;;-1];
	me=CookiesGetMe[cookie,auth];
	Switch[me["error","code"],
		100,Text@Style["验证失败, 请刷新此 cookie",Darker@Red]//Return,
		40352,Text@Style["该账号已被限制, 请手动登陆解除限制",Darker@Red]//Return,
		_,Text@Style["Login Successfully!",Darker@Green]//Print
	];
	img=ImageResize[URLExecute[StringTake[me["avatar_url"],1;;-6]<>"r.jpg","jpg"],52];
	ZhihuLinkUserObject[<|
		"cookies"->cookie,
		"auth"->auth,
		"user"->me["url_token"],
		"img"->img,
		"time"->Now
	|>]
];
CookiesTimeCheck[t_]:=Piecewise[
	{
		{Text@Style["\[Checkmark] Success!",Darker@Green],QuantityMagnitude@t<3*86400},
		{Text@Style["× Fail !!",Red],QuantityMagnitude@t>86400*25}
	},Text@Style["¿ Need Refresh",Purple]
];
Format[ZhihuLinkUserObject[___],OutputForm]:="ZhihuLinkUserObject[<>]";
Format[ZhihuLinkUserObject[___],InputForm]:="ZhihuLinkUserObject[<>]";
ZhihuLinkUserObjectQ[asc_?AssociationQ]:=AllTrue[{"cookies","auth","user"},KeyExistsQ[asc,#]&];
ZhihuLinkUserObjectQ[_]=False;
ZhihuLinkUserObject/:MakeBoxes[obj:ZhihuLinkUserObject[asc_?ZhihuLinkUserObjectQ],form:(StandardForm|TraditionalForm)]:=Module[
	{above,below},
	above={
		{BoxForm`SummaryItem[{"KeyID: ",Style[Hash@asc["cookies"], DigitBlock -> 5, NumberSeparator -> "-"]}],SpanFromLeft},
		{BoxForm`SummaryItem[{"User: ",Text@Style[asc["user"],Darker@Blue]}],SpanFromLeft},
		{BoxForm`SummaryItem[{"Validity: ",CookiesTimeCheck[Now-asc["time"]]}],SpanFromLeft}
	};
	below={};
	BoxForm`ArrangeSummaryBox[
		"ServiceObject",
		obj,
		asc["img"],
		above,
		below,
		form,
		"Interpretable"->Automatic
	]
];

(* ::Subsubsection:: *)
(*ObjectPost*)
Answer2Data[post_]:=Block[
	{title=post["question","title"],qa,link},
	qa=<|"q"->post["question","id"],"a"->post["id"]|>;
	link=StringTemplate["https://www.zhihu.com/questions/`q`/answers/`a`"][qa];
	<|
		"title"->Hyperlink[title,link],
		"vote"->post["voteup_count"],
		"comment"->post["comment_count"],
		"created time"->FromUnixTime@post["created_time"]
	|>
];
Article2Data[post_]:=Block[
	{title=post["title"],link=post["url"]},
	<|
		"title"->Hyperlink[title,link],
		"vote"->post["voteup_count"],
		"comment"->post["comment_count"],
		"created time"->FromUnixTime@post["created"]
	|>
];
Options[ObjectPost]={SortBy->"vote",Times->True,Save->False};
ObjectPost[user_String,OptionsPattern[]]:=Block[
	{ans,art,data,now=Now},
	If[OptionValue[Save],
		ZhihuAnswerBackup[user];
		Return[$ZhihuLinkMarkdown]
	];
	ans=ZhihuLinkUserAnswer[user,Save->False,Extension->"data[*].voteup_count,comment_count"];
	art=ZhihuLinkUserArticle[user,Save->False,Extension->"data[*].voteup_count,comment_count"];
	data=Reverse@Dataset[Join[Answer2Data/@ans,Article2Data/@art]][SortBy[OptionValue[SortBy]]];
	If[OptionValue[Times],Echo[Now-now,"Time Used: "]];
	Return@data
];
ZhihuLinkUserObject[ass_]["Post"]:=With[
	{
		$ZhihuCookie=Lookup[ass,"cookie"],
		$ZhihuAuth=Lookup[ass,"auth"]
	},
	ObjectPost[Lookup[ass,"user"]];
];
ZhihuLinkUserObject[ass_]["Post",ops_List]:=With[
	{
		$ZhihuCookie=Lookup[ass,"cookie"],
		$ZhihuAuth=Lookup[ass,"auth"]
	},
		ObjectPost@@ops
];
(* ::Subsubsection:: *)
(*ObjectFollow*)


(* ::Subsubsection:: *)
(*ObjectFavor*)

(* ::Subsection::Closed:: *)
(*附加设置*)
End[] ;
SetAttributes[
	{},
	{Protected,ReadProtected}
];
EndPackage[]
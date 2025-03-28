Class HFD.Transformation.Main Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

/// w ##class(HFD.Transformation.Main).test()
ClassMethod test() As %Status
{
	#Dim ex As %Exception.StatusException
	//
	//
	Try {
		Set sc=$$$OK
		Set hl7=##class(%Dictionary.CompiledXData).IDKEYOpen($CLASSNAME(), "HL7Test").Data
		Set hl7=$PIECE($PIECE(hl7.Read(),"<Request>",2),"</Request>",1)
		Set hl7=$REPLACE($REPLACE(hl7,"<![CDATA[",""),"]]>","")
		Set hl7=$REPLACE(hl7,$CHAR(13,10,9),$CHAR(10))
		#dim hl7Obj as EnsLib.HL7.Message = ##class(EnsLib.HL7.Message).ImportFromString(hl7,.sc)
		;w hl7Obj.OutputToString()
		
		;Set writer=##class(%XML.Writer).%New()
	 	;Set writer.Indent=1
	 	;Do writer.RootObject(hl7)
		Write !!,"-------------",!
		Set sc=##class(HFD.Transformation.Main).Transform(hl7Obj,.target)
		//zw sc,target
		;w target.%ToJSON()
		ZWrite sc
		If $$$ISERR(sc){
			Do $SYSTEM.Status.DisplayError(sc)
		}
		/*
		Set writer=##class(%XML.Writer).%New()
		Set writer.Indent=1
		Do writer.RootObject(target)
		*/
		//
	} Catch (ex) {
		Set sc=ex.AsStatus()
	}
	//
	Quit sc
}

XData HL7Test
{
<Request>
	<![CDATA[
	MSH|^~\&|SMARTLINX_11.4_PHSWEB1511|MGH|||20231116154851.039-0500||ORU^R01^ORU_R01|3b161548510506b3|P|2.6|||AL|NE||8859/1|||IHE_PCD_001^IHE PCD^1.3.6.1.4.1.19376.1.6.1.1.1^ISO|
	PID|||8238685||STANCHINA^CECILIA^^^^^L||19610830|F||||||||||3563877973|
	PV1||I|MGH B07^B0758^B0758 A^MGH^^^^^MON1|
	OBR|1|1435^CAPSULE^AC3BCD02F7AA405E^EUI-64|1435^CAPSULE^AC3BCD02F7AA405E^EUI-64|69121^MDC_OBS_WAVE_CTS^MDC|||20231116154845.706-0500|20231116154850.706-0500||MGHMGHB07_B0758A|||MGHMGHB07_B0758A||||||||DatexA_5.2.19.12_CARESCAPE B850_Datex|
	OBX|1||69965^MDC_DEV_MON_PHYSIO_MULTI_PARAM_MDS^MDC|1.0.0.0|||||||X|
	OBX|2|ST|67886^MDC_ATTR_ID_SOFT^MDC|1.0.0.50224|MON1||||||F|
	OBX|3||70658^MDC_DEV_GENERAL_VMD^MDC|1.99.0.0|||||||X|
	OBX|4||70659^MDC_DEV_GENERAL_CHAN^MDC|1.99.1.0|||||||X|
	OBX|5|NA|27^^CAPSULE|1.99.1.27|-33^-30^-29^-29^-28^-27^-29^-29^-26^-24^-19^-15^-14^-13^-13^-15^-12^-10^-10^-8^-11^-14^-17^-16^-16^-16^-14^-11^-11^-12^-11^-9^-5^0^0^3^6^5^3^0^-4^-7^-9^-11^-12^-13^-18^-21^-23^-24^-23^-24^-22^-18^-13^-8^-7^-7^-3^-1^-2^-4^-6^-7^-10^-10^-9^-7^-7^-9^-14^-17^-20^-20^-15^-6^5^13^19^20^18^15^11^8^6^3^0^-3^-8^-13^-17^-21^-21^-23^-21^-18^-13^-12^-10^-11^-12^-13^-13^-12^-12^-14^-14^-14^-13^-11^-10^-11^-12^-12^-11^-9^-7^-6^-2^1^3^5^9^13^15^18^21^26^31^34^36^37^34^28^21^13^6^0^-4^-7^-7^-9^-9^-8^-8^-8^-8^-10^-13^-15^-18^-19^-19^-20^-18^-14^-13^-12^-13^-15^-14^-12^-8^-2^4^7^8^9^9^9^10^9^12^14^13^13^14^14^13^10^8^7^6^5^0^-5^-14^-24^-29^-31^-29^-29^-29^-31^-35^-39^-39^-35^-29^-26^-24^-25^-30^-31^-30^-26^-23^-21^-21^-22^-22^-21^-21^-20^-19^-16^-14^-9^-5^1^3^4^6^7^9^11^12^13^13^11^6^-1^-6^-12^-17^-21^-21^-20^-22^-24^-24^-22^-23^-25^-29^-34^-38^-42^-44^-42^-39^-40^-39^-38^-37^-36^-34^-33^-35^-35^-35^-35^-32^-30^-27^-24^-20^-16^-10^-5^2^7^9^9^6^1^-4^-9^-11^-12^-12^-14^-16^-18^-24^-31^-38^-45^-51^-55^-60^-67^-71^-70^-69^-68^-65^-65^-69^-71^-75^-74^-72^-73^-72^-70^-71^-71^-69^-66^-62^-60^-60^-57^-53^-49^-41^-34^-27^-22^-20^-22^-19^-16^-14^-14^-16^-19^-24^-27^-30^-32^-31^-30^-34^-32^-29^-32^-31^-34^-40^-39^-40^-42^-40^-40^-38^-34^-33^-33^-32^-35^-37^-37^-36^-34^-31^-32^-33^-30^-26^-17^-2^15^28^32^29^23^19^17^18^19^16^12^8^1^-3^-3^-5^-5^-6^-8^-10^-14^-18^-22^-23^-26^-28^-29^-29^-30^-28^-24^-18^-15^-13^-13^-11^-7^7^39^91^160^233^293^325^325^293^236^176^121^84^68^66^73^80^79^65^48^28^13^1^-7^-11^-16^-20^-25^-28^-32^-37^-38^-38^-35^-31^-28^-29^-31^-34^-38^-36^-31^-26^-24^-23^-24^-24^-22^-21^-20^-16^-17^-17^-12^-10^-6^1^3^12^22^28^35^39^43^47^51^55^58^60^58^57^53^50^48^46^44^45^45^45^47^48^48^51^54^57^62^64^68^75^78^79^77^77^79^82^88^97^99^99^97^98^101^101^102^101^98^98^96^94^92^88^84^82^83^84^82^78^74^73^71^71^69^66^63^60^56^53^49^41^33^31^32^35^41^45^48^49^47^47^48^48^49^46^43^41^40^38^37^37^35^36^36^33^30^26^22^22^23^23^23^21^22^21^21^17^9^1^-5^-10^-14^-17^-23^-25^-27^-24^-22^-21^-19^-17^-14^-12^-14^-17^-22^-28^-33^-37^-37^-39^-42^-43^-44^-47^-50^-50^-47^-40^-23^10^61^129^207^272^309^308^275^226^170^116^75^51^39^40^48^52^48^37^24^14^9^6^2^0^0^0^0^0^-2^-4^-2^-1^-1^-3^-7^-12^-13^-11^-10^-8^-10^-15^-16^-15^-11^-5^-1^-2^-2^-3^-3^-2^0^1^2^0^0^3^5^8^10^11^14^15^16^14^17^19^23^25^25^24^21^21^21^26^31^30^31^31^35^38^43^49^56^61^69^82^93^105^113^115^117^118^120^123^125^124^123^122^119^115^112^105^94^83^71^59^50^45^45^43^41^37^34^31^26^22^17^12^8^4^1^-1^-2^-2^-2^-2^2^6^9^12^14^16^15^14^17^21^22^20^18^16^15^15^20^23^24^21^19^17^16^13^12^13^14^15^17^17^16^17^18^21^23^23^19^12^6^3^1^2^2^1^2^0^-1^-3^-3^-6^-10^-17^-23^-26^-29^-27^-25^-23^-21^-20^-20^-18^-17^-22^-28^-35^-40^-40^-41^-41^-37^-34^-32^-30^-29^-29^-27^-26^-24^-17^-10^-6^-3^-4^-3^0^1^3^5^3^2^1^0^0^-1^-8^-14^-18^-20^-21^-20^-21^-19^-17^-16^-16^-13^-14^-16^-16^-17^-16^-13^-13^-11^-7^-3^0^3^4^6^10^13^16^21^24^24^27^29^29^29^28^25^23^25^23^23^22^19^19^20^20^18^14^6^3^0^0^0^1^2^4^2^0^-5^-12^-17^-18^-14^0^22^57^107^171^240^296^321^316^278^220^161^106^71^52^44^48^54^53^47^35^23^12^2^-4^-7^-9^-10^-11^-12^-13^-15^-18^-20^-23^-25^-27^-25^-20^-18^-17^-16^-17^-18^-19^-24^-24^-23^-21^-20^-19^-20^-20^-21^-18^-14^-11^-6^-1^5^11^18^22^26^28^29^31^35^41^48^55^59^61^60^58^58^61^68^72^75^75^73^72^73^74^81^87^91^97^101^105^107^105^100^98^97^98^101^101^100^98^96^93^92^91^88^87^85^81^78^74^70^65^62^59^60^60^62^63^64^61^60^57^57^56^54^53^52^54^53^51^48^43^41^38^38^39^40^39^40^38^37^34^29^25^19^11^5^4^7^11^15^16^13^11^11^13^18^21^21^20^18^16^18^19^20^20^21^21^22^20^16^11^6^3^0^2^4^2^0^-1^-6^-11^-18^-25^-32^-36^-40^-44^-49^-54^-61^-65^-65^-64^-61^-60^-62^-67^-67^-67^-66^-59^-51^-43^-33^-26^-22^-17^-16^-17^-15^-14^-14^-11^-8^-6^-4^-2^0^1^1^0^1^2^2^3^3^3^2^-1^-3^-3^-3^-4^-5^-7^-9^-9^-11^-11^-6^-4^-5^-8^-13^-19^-21^-20^-13^-6^-1^0^2^4^6^8^9^10^11^11^11^12^11^11^12^13^16^18^18^18^19^18^18^17^14^10^5^2^3^2^1^-4^-9^-12^-10^-8^-7^-10^-16^-22^-27^-27^-27^-27^-27^-29^-28^-24^-18^-13^-6^1^12^23^39^62^99^152^220^283^324^331^304^254^192^133^87^57^44^40^45^47^42^28^14^4^-1^-2^-4^-3^-1^2^6^7^4^1^-2^-6^-6^-7^-9^-9^-7^-7^-6^-5^-5^-5^-3^-2^1^2^2^1^-2^-5^-8^-8^-8^-9^-12^-14^-18^-18^-14^-9^-1^1^2^4^11^18^28^36^42^49^56^64^74^84^92^99^106^110^113^114^114^115^117^119^119^117^113^113^112^113^116^116^114^111^109^108^111^116^119^120^119^113^108^104^99^97^95^92^90^86^81^75^69^65^64^63^63^64^64^65^65^64^66^66^66^68^69^70^68^67^65^61^58^56^53^51^46^40^37^33^28^26^22^17^14^14^16^19^22^22^25^27^30^32^33^31^29^30^33^36^39^41^39^36^31^26^23^22^21^18^14^9^7^4^2^2^-1^-3^-6^-10^-17^-23^-28^-31^-31^-32^-33^-35^-35^-35^-30^-23^-16^-10^-7^-7^-8^-9^-9^-10^-8^-6^-6^-1^0^-2^-4^-5^-5^-2^1^3^4^3^0^-4^-4^-5^-8^-8^-8^-8^-6^-7^-9^-11^-13^-17^-18^-18^-19^-17^-16^-14^-12^-11^-9^-9^-10^-11^-11^-11^-8^-4^0^5^9^9^7^5^6^7^7^6^4^2^0^0^1^2^4^7^13^17^20^19^19^15^11^10^9^8^9^10^14^30^62^113^180^244^292^309^291^247^189^133^85^54^42^43^53^58^54^44^27^9^-1^-7^-14^-18^-23^-25^-23^-24^-26^-27^-25|uV^uV^UCUM|||||F|||20231116154845.706-0500|
	OBX|6|NM|67981^MDC_ATTR_TIME_PD_SAMP^MDC|1.99.1.27.1|3.333333|ms^ms^UCUM|||||F|||20231116154845.706-0500|
	]]>
	</Request>
}

/// D ##class(HFD.Transformation.Main).infoPerDay()
ClassMethod infoPerDay() As %Integer
{
	Set allResults=0
	Set allCnt=0
	Set date=""
	For {
		Set date=$ORDER(^IRIS.Temp.Hl7Log("hl7",date))
		If date="" Quit

		Set endTime=0
		Set result=0
		Set cnt=0
		Set ratio=0.5
		Set min=9999
		Set max=0
		Set pos=""
		For {
			Set pos=$ORDER(^IRIS.Temp.Hl7Log("hl7",date,pos))
			If pos="" Quit
			//
			If '$DATA(^IRIS.Temp.Hl7Log("hl7",date,pos,"end")) Continue
			If ^IRIS.Temp.Hl7Log("hl7",date,pos,"end")>endTime {
				Set endTime=pos ; ^IRIS.Temp.Hl7Log("hl7",date,pos,"end")
			}
			Set time=^IRIS.Temp.Hl7Log("hl7",date,pos,"end") - ^IRIS.Temp.Hl7Log("hl7",date,pos,"start")
			Set result=result + time
			If time<min {
				Set min=time
			}
			If time>max {
				Set max=time
			}
			If max>ratio {
				Set cnt=cnt+1
				;zw pos
				;q
			}
			/*
			if result>1 {
				zw pos
				quit
			}
			*/
		}
		ZWrite result,endTime
		Set cntMsg=^IRIS.Temp.Hl7Log("hl7",date)
		Set allCnt=allCnt + cntMsg
		Set allResults=allResults + result
		Set average=$JUSTIFY(cntMsg/result,0,2)
		Write !,"*** "_date_" ***"
		Write !,"Number of messages: "_cntMsg
		Write !,"Time spent: "_$JUSTIFY(result,0,2)_" sec"
		Write !,"Min time: "_min
		Write !,"Max time: "_max
		Write !,"Average namber per sec: "_average
		Write !
		;zw cnt
	}

	Write !,"Summary: "
	Write !,"Number of messages: "_allCnt
	Write !,"Time spent: "_$JUSTIFY(allResults,0,2)_" sec"
	Set average=$JUSTIFY(allCnt/allResults,0,2)
	Write !,"Average namber per sec: "_average

	Write !,"zzz: "_(^IRIS.Temp.Hl7Log("hl7",$ZDATE(+$HOROLOG,8),$ORDER(^IRIS.Temp.Hl7Log("hl7",$ZDATE(+$HOROLOG,8),""),-1),"end") - ^IRIS.Temp.Hl7Log("hl7",$ZDATE(+$HOROLOG,8),1,"start"))


	Quit allResults
}

// segmentID, deviceID, patientID, timeStart As %Library.PosixTime, timePerSample, values

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.6:ORU_R01' targetDocType='2.6:ORU_R01' create='new' language='objectscript' >
	<code>
	<![CDATA[ 
	Set pos=$SEQUENCE(^IRIS.Temp.Hl7Log("hl7",$ZD(+$H,8)))
	Set ^IRIS.Temp.Hl7Log("hl7",$ZD(+$H,8),pos,"start")=$ZHorolog	
	]]>
	</code>
	<assign value='source.{MSH}' property='mshLine' action='set' />
	<foreach property='source.{PIDgrpgrp()}' key='k1' >
		<comment>
		<annotation>PID segment</annotation>
		</comment>		
		<assign value='source.{PIDgrpgrp(k1).PIDgrp.PID}' property='pidLine' action='set' />
		<foreach property='source.{PIDgrpgrp(k1).ORCgrp()}' key='k2' >
			<comment>
			<annotation>OBR segment</annotation>
			</comment>
			<assign value='source.{PIDgrpgrp(k1).ORCgrp(k2).OBR}' property='obrLine' action='set' />
			
			<assign value='$Extract(source.{PIDgrpgrp(k1).ORCgrp(k2).OBR:7},1,18)' property='observationStart' action='set' />
			<assign value='$Extract(source.{PIDgrpgrp(k1).ORCgrp(k2).OBR:8},1,18)' property='observationEnd' action='set' />
			<assign value='$e(observationStart,1,4)_"-"_$e(observationStart,5,6)_"-"_$e(observationStart,7,8)_" "_$e(observationStart,9,10)_":"_$e(observationStart,11,12)_":"_$e(observationStart,13,14)_"."_$e(observationStart,16,18)' property='odbcStart' action='set' />
			<assign value='##class(%Library.PosixTime).OdbcToLogical(odbcStart)' property='tsStart' action='set' />
			<assign value='$e(observationStart,1,6)' property='epoch' action='set' />
			<foreach property='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp()}' key='k3' >
				<comment>
				<annotation>OBX segment</annotation>
				</comment>   
				<assign value='0' property='interval' action='set' />
				<assign value='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX}' property='obxLine' action='set' />          
                <assign value='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:5}' property='observationValue' action='set' />
				<if condition='observationValue &apos;= ""' >
					<true>
					<if condition='$find(observationValue,"^")' >
						<true>
							<assign value='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:13}' property='obx13' action='set' />
							<if condition='+obx13' >
							<true>
								<assign value='obx13 * 1000' property='interval' action='set' />
							</true>
							<false>
								<assign value='$p(source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3+1).OBX:3},"^",1)' property='nextObsId' action='set' />
								<if condition='nextObsId = 67981' >
								<true>
									<assign value='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3+1).OBX:5} * 1000' property='interval' action='set' />
									<if condition='+interval' >
									<true>
										<code>
										<![CDATA[ 						                        
											set k3 = k3+1
										]]>
										</code>										
									</true>
									</if>
								</true>
								</if>
							</false>
							</if>
							<!--
							<if condition='&apos;interval' >
								<true>
									<break />
								</true>
							</if>
							-->
						</true>
					</if>

					<assign value='##class(HFD.Data.SeriesMeta).GetID(epoch, mshLine, pidLine, obrLine, obxLine,tsStart)' property='seriesID' action='set' />
					
					<if condition='+interval' >
					<annotation>It is for wave</annotation>
					<true>
						<code>
						<![CDATA[ 						                        
							do ##class(HFD.Utils).SaveWaveform(observationStart, epoch, seriesID, observationValue, tsStart, interval, .locked, 0)
						]]></code>						
					</true>
					<false>
						<if condition='$find(observationValue,"^")' >
						<true>
							<trace value='"Found series values but no interval!"' />
						</true>
						<false>
							<code>
							<![CDATA[ 
								do ##class(HFD.Utils).SaveParameter(observationStart, epoch, seriesID, observationValue, tsStart, .locked, 0)
							]]>
							</code>						
						</false>
						</if>
					</false>
					</if>
					</true>
				</if>
			</foreach>
		</foreach>
	</foreach>
	<code>
	<![CDATA[ 
		if $d(locked) { lock -^HFD.Series.V($lg(locked),$lg(locked,2),$lg(locked,3)) }
		;Set ^IRIS.Temp.Hl7Log("hl7","ztime")=$ZHorolog
		Set ^IRIS.Temp.Hl7Log("hl7",$ZD(+$H,8),pos,"end")=$ZHorolog	
	]]></code>
</transform>
}

}

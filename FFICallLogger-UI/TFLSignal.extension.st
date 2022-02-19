Extension { #name : #TFLSignal }

{ #category : #'*FFICallLogger-UI' }
TFLSignal >> stackAsStringToCopyAndPaste [

	^ String streamContents: [ :aStream | 
		  stack
			  do: [ :element | aStream print: element ]
			  separatedBy: [ aStream cr ] ]
]

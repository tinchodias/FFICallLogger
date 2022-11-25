"
I'm a Beacon signal with information about a ThreadedFFI call that was just executed.

A started `TFLCallLogger` instance records me. Browse its class comment for more information.

My instances have two states: ""initialized"" and ""prepared"". The method `TFLSignal>>#prepareAsRecording` mutates an instance as a kind of snapshot, so posterior modifications on the original FFI call object are not lost. This is a performance optimization, to avoid preparing instances that are filtered.

"
Class {
	#name : #TFLSignal,
	#superclass : #Announcement,
	#instVars : [
		'arguments',
		'answer',
		'moduleName',
		'functionName',
		'stack',
		'microsecondClockValue',
		'processId'
	],
	#classInstVars : [
		'ffiInvokerMetalink'
	],
	#category : #'FFICallLogger-Core'
}

{ #category : #installation }
TFLSignal class >> ffiInvokerASTNode [

	^ self ffiInvokerMethod ast body statements last
]

{ #category : #convenience }
TFLSignal class >> ffiInvokerMethod [
	"Answer the ThreadedFFI method where this signal installs."
	<script: 'self ffiInvokerMethod browse'>

	^ TFSameThreadRunner>>#invokeFunction:withArguments:
]

{ #category : #'instance creation' }
TFLSignal class >> function: aFunction arguments: aCollection answer: anObject stack: anArrayOfContexts [

	^ self basicNew
		  initializeWithFunction: aFunction
		  arguments: aCollection
		  answer: anObject
		  stack: anArrayOfContexts;
		  yourself
]

{ #category : #initialization }
TFLSignal class >> initialize [

	SystemVersion current major < 11
		ifTrue: [ self initializeBeforePharo11 ]
		ifFalse: [ self initializeAfterPharo11 ]
]

{ #category : #initialization }
TFLSignal class >> initializeAfterPharo11 [

	self
		assert: self ffiInvokerMethod tempNames = #(#function #aCollection)
		description: 'Unexpected source code on FFI invoker'.
	
	ffiInvokerMetalink := MetaLink new
		metaObject: [ :c :answer |
			| answerOrNoAnswer relevantStack aSignal |

			"Nasty way to detect void-returning calls"
			answerOrNoAnswer :=
				answer className = #TFSameThreadCall
					ifTrue: [ TFLNoAnswer instance ]
					ifFalse: [ answer ].

			"Reject runner's invokeFunction"
			relevantStack := c stack allButFirst: 1.

			aSignal := TFLSignal
				function: (c tempNamed: #function)
				arguments: (c tempNamed: #aCollection)
				answer: answerOrNoAnswer
				stack: relevantStack.
			
			aSignal emit ];
		arguments: #(context value);
		selector: #value:value:;
		options: #(- optionCompileOnLinkInstallation);
		control: #before;
		yourself

]

{ #category : #initialization }
TFLSignal class >> initializeBeforePharo11 [

	self
		assert: self ffiInvokerMethod tempNames = #(#aTFExternalFunction #aCollection)
		description: 'Unexpected source code on FFI invoker'.
	
	ffiInvokerMetalink := MetaLink new
		metaObject: [ :c :answer |
			| answerOrNoAnswer relevantStack aSignal |

			"Nasty way to detect void-returning calls"
			answerOrNoAnswer :=
				answer className = #TFSameThreadCall
					ifTrue: [ TFLNoAnswer instance ]
					ifFalse: [ answer ].

			"Reject runner's invokeFunction"
			relevantStack := c stack allButFirst: 1.

			aSignal := TFLSignal
				function: (c tempNamed: #aTFExternalFunction)
				arguments: (c tempNamed: #aCollection)
				answer: answerOrNoAnswer
				stack: relevantStack.
			
			aSignal emit ];
		arguments: #(context value);
		selector: #value:value:;
		options: #(- optionCompileOnLinkInstallation);
		control: #before;
		yourself

]

{ #category : #installation }
TFLSignal class >> install [
	<script>

	self isInstalled ifFalse: [
		self ffiInvokerASTNode link: ffiInvokerMetalink ]
]

{ #category : #installation }
TFLSignal class >> isInstalled [
	"
	self isInstalled
	"

	^ self ffiInvokerASTNode hasMetalink: ffiInvokerMetalink
]

{ #category : #installation }
TFLSignal class >> uninstall [
	<script>

	self isInstalled ifTrue: [
		self ffiInvokerASTNode removeLink: ffiInvokerMetalink ]
]

{ #category : #accessing }
TFLSignal >> answer [

	^ answer
]

{ #category : #accessing }
TFLSignal >> arguments [

	^ arguments
]

{ #category : #converting }
TFLSignal >> asBeaconSignal [
	^ self
]

{ #category : #accessing }
TFLSignal >> functionName [

	^ functionName
]

{ #category : #initialization }
TFLSignal >> initializeWithFunction: aFunction arguments: aCollection answer: anObject stack: anArrayOfContexts [

	self initialize.
	microsecondClockValue := DateAndTime clock microsecondClockValue.
	processId := Processor activeProcess name.
	moduleName := aFunction moduleName.
	functionName := aFunction functionName.
	arguments := aCollection.
	answer := anObject.
	stack := anArrayOfContexts
]

{ #category : #accessing }
TFLSignal >> moduleName [

	^ moduleName
]

{ #category : #accessing }
TFLSignal >> name [

	^ 'FFI Call'
]

{ #category : #printing }
TFLSignal >> oneLineContents [

	^ String streamContents: [ :s | self printOneLineContentsOn: s ]
]

{ #category : #accessing }
TFLSignal >> prepareAsRecording [
	"Copy collaborators as an 'immutable' objects."

	arguments := arguments collect: [ :each | each asTFLRecording ].
	answer := answer asTFLRecording.
]

{ #category : #printing }
TFLSignal >> printOn: stream [

	self printOneLineContentsOn: stream
]

{ #category : #printing }
TFLSignal >> printOneLineContentsOn: aStream [

	aStream
"		print: self timestamp;
		nextPutAll: ' | ';
		nextPutAll: processId;
		nextPutAll: ' | ';
		nextPutAll: self shortModuleName;
		nextPutAll: ' | ';"
		nextPutAll: functionName";
		nextPut: $(;
		nextPutAll: arguments asCommaString;
		nextPutAll: ') => ';
		print: answer
"
]

{ #category : #accessing }
TFLSignal >> processId [

	^ processId
]

{ #category : #accessing }
TFLSignal >> sender [
	"Answer the CompiledMethod that performed the call."

	^ stack first method
]

{ #category : #accessing }
TFLSignal >> shortModuleName [

	^ moduleName asPath basenameWithoutExtension
]

{ #category : #accessing }
TFLSignal >> stack [

	^ stack
]

{ #category : #accessing }
TFLSignal >> timestamp [
	
	^ DateAndTime fromMicrosecondClockValue: microsecondClockValue
]

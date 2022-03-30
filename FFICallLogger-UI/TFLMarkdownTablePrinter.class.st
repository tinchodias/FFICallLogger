"
I'm capable of printing a collection of collection of Strings in the Markdown table format.
"
Class {
	#name : #TFLMarkdownTablePrinter,
	#superclass : #Object,
	#instVars : [
		'rows',
		'stream',
		'horizontalMargin',
		'columnWidths',
		'newLineString'
	],
	#category : #'FFICallLogger-UI'
}

{ #category : #accessing }
TFLMarkdownTablePrinter >> columnWidths [

	^ columnWidths
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> horizontalMargin [

	^ horizontalMargin
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> horizontalMargin: aPositiveInteger [

	horizontalMargin := aPositiveInteger
]

{ #category : #initialization }
TFLMarkdownTablePrinter >> initialize [

	super initialize.
	
	horizontalMargin := 1.
	newLineString := String crlf.
]

{ #category : #private }
TFLMarkdownTablePrinter >> isColumnIndexLeftAligned: columnIndex [

	^ columnIndex = 1
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> newLineString [

	^ newLineString
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> newLineString: aString [

	newLineString := aString
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> rows: aCollectionOfCollectionsOfStrings [

	rows := aCollectionOfCollectionsOfStrings
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> stream [

	^ stream
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> stream: aWriteStream [

	stream := aWriteStream
]

{ #category : #writing }
TFLMarkdownTablePrinter >> write [

	columnWidths := rows
		inject: (Array new: rows first size withAll: 0)
		into: [ :maxLengthsSoFar :row | 
			maxLengthsSoFar
				with: row
				collect: [ :columnMaxLength :each |
					columnMaxLength max: each size ] ].
			
	rows readStreamDo: [ :rowStream |
		self writeRow: rowStream next.
		self writeHorizontalLine.
		[ rowStream atEnd ] whileFalse: [ 
			self writeRow: rowStream next ] ].

]

{ #category : #private }
TFLMarkdownTablePrinter >> writeCell: aString columnIndex: columnIndex [

	| columnWidth padding |
	columnWidth := columnWidths at: columnIndex.
	padding := String new: columnWidth - aString size withAll: Character space.

	(self isColumnIndexLeftAligned: columnIndex)
		ifTrue: [ stream << aString; << padding ]
		ifFalse: [ stream << padding; << aString ]

]

{ #category : #private }
TFLMarkdownTablePrinter >> writeHoritontalTick [

	stream nextPut: $-
]

{ #category : #private }
TFLMarkdownTablePrinter >> writeHorizontalLine [

	columnWidths
		do: [ :each |
			self writeVerticalTick.
			(each + (horizontalMargin * 2)) timesRepeat: [ self writeHoritontalTick ] ].
	self writeVerticalTick.
	self writeNewLine.

]

{ #category : #private }
TFLMarkdownTablePrinter >> writeMargin [

	stream nextPut: Character space
]

{ #category : #private }
TFLMarkdownTablePrinter >> writeNewLine [

	stream nextPutAll: newLineString
]

{ #category : #private }
TFLMarkdownTablePrinter >> writeRow: aCollectionOfStrings [

	| columnIndex |
	columnIndex := 1.
	aCollectionOfStrings do: [ :each |
		self writeVerticalTick.
		self writeMargin.
		self writeCell: each columnIndex: columnIndex.
		columnIndex := columnIndex + 1.
		self writeMargin ].
	self
		writeVerticalTick;
		writeNewLine.

]

{ #category : #private }
TFLMarkdownTablePrinter >> writeVerticalTick [

	stream nextPut: $|
]

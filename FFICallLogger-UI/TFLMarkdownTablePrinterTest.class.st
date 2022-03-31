Class {
	#name : #TFLMarkdownTablePrinterTest,
	#superclass : #TestCase,
	#category : #'FFICallLogger-UI'
}

{ #category : #tests }
TFLMarkdownTablePrinterTest >> exampleRows [

	^ #(
		#(c1 c2 c3)
		#(o oo ooo)
		#(oo oooo oooooo)
		)
]

{ #category : #tests }
TFLMarkdownTablePrinterTest >> testWriteDefault [
	"By default, all columns are left-aligned."

	| print |
	print := String streamContents: [ :stream |
		TFLMarkdownTablePrinter new
			stream: stream;
			rows: self exampleRows;
			write ].

	self
		assert: print withUnixLineEndings
		equals: 
'| c1 | c2   | c3     |
|----|------|--------|
| o  | oo   | ooo    |
| oo | oooo | oooooo |
' withUnixLineEndings.
]

{ #category : #tests }
TFLMarkdownTablePrinterTest >> testWriteOnlyRowNamesAlignedLeft [
	"Useful when there are row names and numeric values in other columns."

	| print |
	print := String streamContents: [ :stream |
		TFLMarkdownTablePrinter new
			stream: stream;
			rows: self exampleRows;
			isColumnLeftAlignedBlock: [ :columnIndex |
				columnIndex = 1 ];
			write ].

	self
		assert: print withUnixLineEndings
		equals: 
'| c1 |   c2 |     c3 |
|----|------|--------|
| o  |   oo |    ooo |
| oo | oooo | oooooo |
' withUnixLineEndings.
]

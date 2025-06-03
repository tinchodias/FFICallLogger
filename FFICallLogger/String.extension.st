Extension { #name : #String }

{ #category : #'*FFICallLogger' }
String >> tflPathBaseName [
	"Answer the basename, assuming I'm a pathstring as in the following example.
	
	{ '/foo/bar.taz'. 'bar.taz'. '/foo/bar'. 'bar'. '/bar' }
		collect: [ :path | path -> path tflPathBaseName ]
	"

	self size to: 1 by: -1 do: [ :index |
		| c |
		c := self at: index.
		c = $. ifTrue: [
			index - 1 to: 1 by: -1 do: [ :startIndex |
				c := self at: startIndex.
				c = $/ ifTrue: [
					^ self copyFrom: startIndex + 1 to: index - 1 ] ].
			^ self copyFrom: 1 to: index - 1 ].
		c = $/ ifTrue: [
			^ self copyFrom: index + 1 to: self size ] ].
	^ self
]

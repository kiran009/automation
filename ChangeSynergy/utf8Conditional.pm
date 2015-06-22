#
# This module will conditionally use the "utf8" module if
# the IBM Rational Change server encoding is set to UTF-8. IBM Rational Change
# sets an evironment variable called SYNERGYChange_encoding with its
# current encoding when a trigger is fired.
#
package ChangeSynergy::utf8Conditional;

if ($ENV{SYNERGYChange_encoding} eq "UTF-8")
{
	eval
	{
		require utf8;
		import utf8;
	};

	if ($@)
	{
		print "Failed to include utf8: " . $@ . "\n";
	}
}

1;
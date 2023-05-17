// Conditional defines for ddablib/vibin

{$UNDEF Supports_ScopedUnitNames}
{$UNDEF CanCompile}
{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 24.0} // Delphi XE3 and later
    {$LEGACYIFEND ON}  // NOTE: this must come before all $IFEND directives
  {$IFEND}
  {$IF CompilerVersion >= 23.0} // Delphi XE2 and later
    {$DEFINE Supports_ScopedUnitNames}
  {$IFEND}
  {$IF CompilerVersion >= 22.0} // Delphi XE and later
    {$DEFINE CanCompile}
  {$IFEND}
{$ENDIF}
{$IFNDEF CanCompile}
  {$MESSAGE FATAL 'Delphi XE or later required'}
{$ENDIF}


sub re($) { $_[0]->slice("(0)"); }
sub im($) { $_[0]->slice("(1)"); }


our $floatformat  = "%4.4g";    # Default print format for long numbers
our $doubleformat = "%6.6g";

$PDL::Complex::_STRINGIZING = 0;

sub string
{
  my($self,$format1,$format2)=@_;
  my @dims = $self->dims;
  return PDL::string($self) if ($dims[0] != 2);

  if ($PDL::Complex::_STRINGIZING)
  {
    return "ALREADY_STRINGIZING_NO_LOOPS";
  }
  local $PDL::Complex::_STRINGIZING = 1;
  my $ndims = $self->getndims;
  if ($self->nelem > $PDL::toolongtoprint)
  {
    return "TOO LONG TO PRINT";
  }
  if ($ndims==0)
  {
    PDL::Core::string($self,$format1);
  }
  return "Null" if $self->isnull;
  return "Empty" if $self->isempty; # Empty piddle
  local $sep  = $PDL::use_commas ? ", " : "  ";
  local $sep2 = $PDL::use_commas ? ", " : "";
  if ($ndims < 3)
  {
    return str1D($self,$format1,$format2);
  }
  else
  {
    return strND($self,$format1,$format2,0);
  }



  sub strND {
    my($self,$format1,$format2,$level)=@_;
    my @dims = $self->dims;

    if ($#dims==2)
    {
      return str2D($self,$format1,$format2,$level);
    }
    else
    {
      my $secbas = join '',map {":,"} @dims[0..$#dims-1];
      my $ret="\n"." "x$level ."["; my $j;
      for ($j=0; $j<$dims[$#dims]; $j++)
      {
        my $sec = $secbas . "($j)";

        $ret .= strND($self->slice($sec),$format1,$format2, $level+1);
        chop $ret; $ret .= $sep2;
      }
      chop $ret if $PDL::use_commas;
      $ret .= "\n" ." "x$level ."]\n";
      return $ret;
    }
  }

  # String 1D array in nice format
  #
  sub str1D {
    my($self,$format1,$format2)=@_;
    barf "Not 1D" if $self->getndims() > 2;
    my $x = PDL::Core::listref_c($self);
    my ($ret,$dformat,$t, $i);

    my $dtype = $self->get_datatype();
    $dformat = $PDL::Complex::floatformat  if $dtype == $PDL_F;
    $dformat = $PDL::Complex::doubleformat if $dtype == $PDL_D;

    $ret = "[" if $self->getndims() > 1;
    my $badflag = $self->badflag();
    for ($i=0; $i<=$#$x; $i++)
    {
      $t = $$x[$i];
      if ( $badflag and $t eq "BAD" )
      {
        # do nothing
      }
      elsif ($format1)
      {
        $t =  sprintf $format1,$t;
      }
      else
      {                         # Default
        if ($dformat && length($t)>7)
        {                       # Try smaller
          $t = sprintf $dformat,$t;
        }
      }
      $ret .= $i % 2 ?
        $i<$#$x ? $t."i$sep" : $t."i"
        : substr($$x[$i+1],0,1) eq "-" ?  "$t " : $t." +";
    }
    $ret.="]" if $self->getndims() > 1;
    return $ret;
  }

  sub str2D {
    my($self,$format1,$format2,$level)=@_;
    my @dims = $self->dims();
    barf "Not 2D" if scalar(@dims)!=3;
    my $x = PDL::Core::listref_c($self);
    my ($i, $f, $t, $len1, $len2, $ret);

    my $dtype = $self->get_datatype();
    my $badflag = $self->badflag();

    my $findmax = 0;

    if (!defined $format1 || !defined $format2 ||
        $format1 eq '' || $format2 eq '') {
      $len1= $len2 = 0;

      if ( $badflag )
      {
        for ($i=0; $i<=$#$x; $i++)
        {
          if ( $$x[$i] eq "BAD" )
          {
            $f = 3;
          }
          else
          {
            $f = length($$x[$i]);
          }
          if ($i % 2)
          {
            $len2 = $f if $f > $len2;
          }
          else
          {
            $len1 = $f if $f > $len1;
          }
        }
      }
      else
      {
        for ($i=0; $i<=$#$x; $i++)
        {
          $f = length($$x[$i]);
          if ($i % 2)
          {
            $len2 = $f if $f > $len2;
          }
          else
          {
            $len1 = $f if $f > $len1;
          }
        }
      }

      $format1 = '%'.$len1.'s';
      $format2 = '%'.$len2.'s';

      if ($len1 > 5)
      {
        if ($dtype == $PDL_F)
        {
          $format1 = $PDL::Complex::floatformat;
          $findmax = 1;
        }
        elsif ($dtype == $PDL_D)
        {
          $format1 = $PDL::Complex::doubleformat;
          $findmax = 1;
        }
        else
        {
          $findmax = 0;
        }
      }
      if ($len2 > 5)
      {
        if ($dtype == $PDL_F)
        {
          $format2 = $PDL::Complex::floatformat;
          $findmax = 1;
        }
        elsif ($dtype == $PDL_D)
        {
          $format2 = $PDL::Complex::doubleformat;
          $findmax = 1;
        }
        else
        {
          $findmax = 0 unless $findmax;
        }
      }
    }

    if ($findmax)
    {
      $len1 = $len2=0;

      if ( $badflag )
      {
        for ($i=0; $i<=$#$x; $i++)
        {
          $findmax = $i % 2;
          if ( $$x[$i] eq 'BAD' )
          {
            $f = 3;
          }
          else
          {
            $f = $findmax ? length(sprintf $format2,$$x[$i]) :
              length(sprintf $format1,$$x[$i]);
          }
          if ($findmax)
          {
            $len2 = $f if $f > $len2;
          }
          else
          {
            $len1 = $f if $f > $len1;
          }
        }
      }
      else
      {
        for ($i=0; $i<=$#$x; $i++)
        {
          if ($i % 2)
          {
            $f = length(sprintf $format2,$$x[$i]);
            $len2 = $f if $f > $len2;
          }
          else
          {
            $f = length(sprintf $format1,$$x[$i]);
            $len1 = $f if $f > $len1;
          }
        }
      }


    }                           # if: $findmax

    $ret = "\n" . ' 'x$level . "[\n";
    {
      my $level = $level+1;
      $ret .= ' 'x$level .'[';
      $len2 += 2;

      for ($i=0; $i<=$#$x; $i++)
      {
        $findmax = $i % 2;
        if ($findmax)
        {
          if ( $badflag and  $$x[$i] eq 'BAD' )
          {
            #||
            #($findmax && $$x[$i - 1 ] eq 'BAD') ||
            #(!$findmax && $$x[$i +1 ] eq 'BAD')){
            $f = "BAD";
          }
          else
          {
            $f = sprintf $format2, $$x[$i];
            if (substr($$x[$i],0,1) eq '-')
            {
              $f.='i';
            }
            else
            {
              $f =~ s/(\s*)(.*)/+$2i/;
            }
          }
          $t = $len2-length($f);
        }
        else
        {
          if ( $badflag and  $$x[$i] eq 'BAD' )
          {
            $f = "BAD";
          }
          else
          {
            $f = sprintf $format1, $$x[$i];
            $t =  $len1-length($f);
          }
        }

        $f = ' 'x$t.$f if $t>0;

        $ret .= $f;
        if (($i+1)%($dims[1]*2))
        {
          $ret.=$sep if $findmax;
        }
        else
        {                       # End of output line
          $ret.=']';
          if ($i==$#$x)
          {                     # very last number
            $ret.="\n";
          }
          else
          {
            $ret.= $sep2."\n" . ' 'x$level .'[';
          }
        }
      }
    }
    $ret .= ' 'x$level."]\n";
    return $ret;
  }
}

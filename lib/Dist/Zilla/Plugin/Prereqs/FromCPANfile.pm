package Dist::Zilla::Plugin::Prereqs::FromCPANfile;

use strict;
our $VERSION = '0.01';

use Module::CPANfile;
use Try::Tiny;
use Moose;
with 'Dist::Zilla::Role::PrereqSource';

sub register_prereqs {
    my $self = shift;

    unless (-e 'cpanfile') {
        $self->log("'cpanfile' is not found in your distribution");
        return;
    }

    try {
        $self->log("Parsing 'cpanfile' to extract prereqs");

        my $cpanfile = Module::CPANfile->load;

        my $prereqs = $cpanfile->prereq_specs;
        for my $phase (keys %$prereqs) {
            for my $type (keys %{$prereqs->{$phase}}) {
                $self->zilla->register_prereqs(
                    { type => $type, phase => $phase },
                    %{$prereqs->{$phase}{$type}},
                );
            }
        }
    } catch {
        $self->log_fatal($_);
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Dist::Zilla::Plugin::Prereqs::FromCPANfile - Parse cpanfile for prereqs

=head1 SYNOPSIS

  # dist.ini
  [Prereqs::FromCPANfile]

=head1 DESCRIPTION

Dist::Zilla::Plugin::Prereqs::FromCPANfile is a L<Dist::Zilla> plugin
to read I<cpanfile> to determine prerequisites for your distribution. This
does the B<opposite of> what L<Dist::Zilla::Plugin::CPANFile> does, which
is to I<create> a C<cpanfile> using the prereqs collected elsewhere.

B<DO NOT USE THIS PLUGIN IN COMBINATION WITH Plugin::CPANFile>. I'm
sure there will be a disaster if you do.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 COPYRIGHT

Copyright 2013- Tatsuhiko Miyagawa

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Module::CPANfile>

=cut

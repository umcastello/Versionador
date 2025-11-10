#!/usr/bin/env perl
use strict;
use warnings;
use File::Copy;
use File::Basename;
use File::Find;
use File::Spec;

# List of files to version (relative paths)
my @files = (
    'host.ini',
    'perlpiper.pl',
    'lib/PerlPiper.pm',
    'playbook.yml'
);

# Function to get the current working directory
my $root_dir = File::Spec->curdir();

# Function to find the highest version
sub get_highest_version {
    my $max_major = 0;
    my $max_minor = -1;  # Start before 0

    # Search for versioned files in the root and views/
    find(sub {
        return unless -f $_;
        if (/\w+_ver_(\d+)\.(\d+)\.\w+/) {
            my ($major, $minor) = ($1, $2);
            if ($major > $max_major || ($major == $max_major && $minor > $max_minor)) {
                $max_major = $major;
                $max_minor = $minor;
            }
        }
    }, $root_dir, File::Spec->catdir($root_dir, 'public'));

    # If no versions found, start at 1.0
    if ($max_minor == -1) {
        $max_major = 1;
        $max_minor = 0;
    } else {
        # Increment minor
        $max_minor++;
    }

    return ($max_major, $max_minor);
}

# Get the next version
my ($major, $minor) = get_highest_version();

# For each file, create versioned copy
foreach my $file (@files) {
    next unless -e $file;  # Skip if original doesn't exist

    my ($name, $dir, $ext) = fileparse($file, qr/\.[^.]*/);
    my $versioned_name = "${name}_ver_${major}.${minor}${ext}";
    my $versioned_path = File::Spec->catfile($dir, $versioned_name);

    copy($file, $versioned_path) or die "Copy failed: $!";
    print "Copied $file to $versioned_path\n";
}

print "Versioning complete to ${major}.${minor}\n";

# =========================================================================
# POD Documentation
# =========================================================================

=encoding utf8

=head1 NAME

versionador.pl - Sistema minimalista de controle de versão em Perl.

=encoding utf8

=head1 SYNOPSIS

B<versionador.pl>

=head1 DESCRIPTION

Este projeto tem por objetivo criar um sistema minimalista de controle de versão, semelhante ao Subversion (SVN), utilizando o poder do Perl.

A principal funcionalidade é gerenciar e rastrear mudanças em arquivos críticos.

=head1 USO

Para utilizar o versionador:

=over 4

=item 1. Edite o arquivo C<versionador.pl> e inclua os arquivos que serão versionados com o caminho relativo.

=item 2. Execute: B<./versionador.pl> sempre antes e depois de qualquer modificação importante em seu código.

=back

=head1 INSTALAÇÃO

Copie o binário (versionador.pl) para um diretório em um sistema Linux que tenha o interpretador Perl instalado.

=head1 AUTHOR

Ulisses Manzo Castello (umcastello@gmail.com)

=head1 SEE ALSO

L<svn>, L<git>

=cut

package JIRA::Status::Config;

use MooseX::Singleton;
use Config::JFDI;



has 'config' => (
    isa => 'HashRef',
    is => 'rw',
    builder => '_load_config',
    lazy => 1,
);

sub _load_config {
    
    # need to locate the damn config-file
    
    my $root = shift->_root_folder;
    my $cfg = Config::JFDI->open(name => 'config', path => $root->stringify, path_to => $root->stringify)
        or croak("Could not load config file");
        
    $cfg->{root_folder} ||= $root;
    
    $cfg;
}

has '_root_folder' => (
    isa => 'Path::Class::Dir',
    coerce => 1,
    is => 'ro',
    builder => '_locate_root_folder'
);

sub _locate_root_folder {
    my $pkg = __PACKAGE__;
    $pkg =~ s|::|/|g;
    $pkg .= ".pm";
    my $pm_file = $INC{$pkg};
    die "Could not locate PM-file: $pm_file" unless ($pm_file and -f $pm_file);
    my $dir = Path::Class::File->new($pm_file)->parent;
    my $root_folder;
    while ($dir->parent and $dir->parent ne $dir) {
        if (-d $dir->subdir('lib') and -d $dir->subdir('static')) {
            $root_folder = $dir;
            last;
        }
        $dir = $dir->parent;
    }
   $dir; 
}



package JIRA::Status::Config::Role;
use Moose::Role;
with qw(MooseX::ConfigFromFile);

has 'config' => (
    isa => 'HashRef',
    is => 'rw',
    builder => '_load_config',
    lazy => 1,
);
sub _load_config {    JIRA::Status::Config->new->config;     }

sub get_config_from_file {  JIRA::Status::Config->new->config;            }

1;
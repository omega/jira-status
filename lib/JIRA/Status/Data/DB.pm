use MooseX::Declare;
namespace JIRA::Status::Data;

class ::Db extends KiokuX::Model {
    use MongoDB::Connection; # Need to do this, since the MongoDB-backend isn't doing it yet
    
    
}

1;

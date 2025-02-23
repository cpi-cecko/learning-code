use utf8;
package MyApp::Schema::Result::Region;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::Result::Region

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<Regions>

=cut

__PACKAGE__->table("Regions");

=head1 ACCESSORS

=head2 regionid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 regiondescription

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "regionid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "regiondescription",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</regionid>

=back

=cut

__PACKAGE__->set_primary_key("regionid");

=head1 RELATIONS

=head2 territories

Type: has_many

Related object: L<MyApp::Schema::Result::Territory>

=cut

__PACKAGE__->has_many(
  "territories",
  "MyApp::Schema::Result::Territory",
  { "foreign.regionid" => "self.regionid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-07-29 08:51:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fJq1VbzHxXgEsvCdGdO3XQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

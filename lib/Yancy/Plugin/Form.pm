package Yancy::Plugin::Form;
our $VERSION = '1.041';
# ABSTRACT: Generate form HTML using various UI libraries

=head1 SYNOPSIS

    use Mojolicious::Lite;
    plugin Yancy => {
        backend => 'pg://localhost/mysite',
        read_schema => 1,
    };
    app->yancy->plugin( 'Form::Bootstrap4' );
    app->routes->get( '/people/:id/edit' )->to(
        'yancy#set',
        schema => 'people',
        template => 'edit_people',
    );
    app->start;
    __DATA__
    @@ edit_people.html.ep
    %= $c->yancy->form->form_for( 'people' );

=head1 DESCRIPTION

The Form plugins generate forms from JSON schemas. Plugin and
application developers can use the form plugin API to make forms, and
then sites can load a specific form library plugin to match the style of
the site.

B<NOTE:> This API is B<EXPERIMENTAL> and will be considered stable in
Yancy version 2.0. Please report any issues you have or features you'd
like to see. Minor things may change before version 2.0, so be sure to
read the release changelog before upgrading.

=head2 Available Libraries

=over

=item * L<Yancy::Plugin::Form::Bootstrap4> - Forms using L<Bootstrap 4|http://getbootstrap.com/docs/4.0/>

=back

=head1 HELPERS

All form plugins add the same helpers with the same arguments so that
applications can use the form plugin that matches their site's
appearance. Yancy plugin and app developers should use form plugins to
build forms so that users can easily customize the form's appearance.

=head2 yancy->form->input

    my $html = $c->yancy->form->input( %args );
    %= $c->yancy->form->plugin( %args );

Create a form input. Usually one of a C<< <input> >>, C<< <textarea >>,
or C<< <select> >> element, but can be more.

C<%args> is a list of name/value pairs with the following keys:

=over

=item type

The type of the input field to create. One of the JSON schema types.
See L<Yancy::Help::Config/Generated Forms> for details on the supported
types.

=item format

For C<string> types, the format the string should take. One of the
supported JSON schema formats, along with some additional ones. See
L<Yancy::Help::Config/Generated Forms> for details on the supported
formats.

=item pattern

A regex pattern to validate the field before submit.

=item required

If true, the field will be marked as required.

=item readonly

If true, the field will be marked as read-only.

=item disabled

If true, the field will be marked as disabled.

=item placeholder

The placeholder for C<< <input> >> and C<< <textarea> >> elements.

=item id

The ID for this field.

=item class

A string with additional classes to add to this field.

=item minlength

The minimum length of the text in this field. Used to validate the form.

=item maxlength

The maximum length of the text in this field. Used to validate the form.

=item minimum

The minimum value for the number in this field. Used to validate the
form.

=item maximum

The maximum value for the number in this field. Used to validate the
form.

=back

Most of these properties are the same as the JSON schema field
properties. See L<Yancy::Help::Config/Generated Forms> for details on
how Yancy translates JSON schema into forms.

=head2 yancy->form->input_for

    my $html = $c->yancy->form->input_for( $schema, $property, %args );
    %= $c->yancy->form->input_for( $schema, $property, %args );

Create a form input for the given schema's property. This creates just
the input field, nothing else. To add a label, see C<field_for>.

=head2 yancy->form->filter_for

    my $html = $c->yancy->form->filter_for( $schema, $property, %args );
    %= $c->yancy->form->filter_for( $schema, $property, %args );

Create a form input suitable as a filter for the given schema's
property. A filter input is never a required field, and always allows
some kind of "blank" value. The filter automatically captures a value
from the query parameter of the same name as the C<$property>. This
creates just the input field, nothing else.

=head2 yancy->form->field_for

    my $html = $c->yancy->form->field_for( $schema, $name );
    %= $c->yancy->form->field_for( $schema, $name );

Generate a field for the given C<$schema> and property C<$name>. The
field will include a C<< <label> >>, the appropriate input (C<< <input>
>>, C<< <select> >>, or otherwise ), and any descriptive text.

=head2 yancy->form->form_for

    my $html = $c->yancy->form->form_for( $schema, %opt );
    %= $c->yancy->form->plugin( $schema, %opt );

Generate a form to edit an item from the given C<$schema>. The form
will include all the fields, a CSRF token, and a single button to submit
the form.

=over

=item method

The C<method> attribute for the C<< <form> >> tag. Defaults to C<POST>.

=item action

The C<action> URL for the C<< <form> >> tag.

=item item

A hashref of values to fill in the form. Defaults to the value of the
C<item> in the stash (which is set by L<Yancy::Controller::Yancy/set>.)

=back

=head1 SEE ALSO

L<Yancy>

=cut

use Mojo::Base 'Mojolicious::Plugin';
use Yancy::Util qw( currym );

sub register {
    my ( $self, $app, $conf ) = @_;
    my $prefix = $conf->{prefix} || 'form';
    for my $method ( qw( form_for field_for input_for filter_for input ) ) {
        $app->helper( "yancy.$prefix.$method" => currym( $self, $method ) );
    }
}

1;

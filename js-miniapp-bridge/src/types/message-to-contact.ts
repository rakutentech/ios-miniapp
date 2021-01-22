/** Message type sent to Contact. */
export interface MessageToContact {
  // Image which will be displayed to contact.
  image: string;
  // Message which will be displayed to contact.
  text: string;
  // Caption for call-to-action button displayed to contact.
  caption: string;
  // Action which the call-to-action button will perform, i.e. a URI with parameters.
  action: string;
  // Title to display to contact.
  title: string;
}

import React, { Component } from 'react';
import './App.css';

const API_URL='http://localhost:9292';
const API_BASIC_AUTHENTICATION_NAME = 'development';
const API_BASIC_AUTHENTICATION_PASSWORD = 'development';

const HEADERS = new Headers();
const BASIS_AUTH = 'Basic ' + btoa(API_BASIC_AUTHENTICATION_NAME + ":" + API_BASIC_AUTHENTICATION_PASSWORD);
HEADERS.set('Authorization', BASIS_AUTH);
HEADERS.set('Accept', 'application/vnd.api+json')
HEADERS.set('Content-Type', 'application/vnd.api+json')

class ContactRow extends React.Component {
  handleEdit(e) {
    this.props.onContactEditClick(e);
  }

  render() {
    const contact = this.props.contact;
    const name = contact.attributes.first_name + ' ' + contact.attributes.last_name;

    return (
      <tr>
        <td><div class="person-photo" style={{backgroundImage: 'url(' + API_URL + '/contacts/' + contact.id + '/image' + ')'}}></div></td>
        <td>{name}</td>
        <td>{contact.attributes.phone}</td>
        <td>{contact.attributes.address}</td>
        <td><button className="btn btn-sm btn-link" onClick={this.handleEdit.bind(this, contact.id)}>Edit</button></td>
      </tr>
    );
  }
}

class ContactTable extends React.Component {
  render() {
    const rows = [];

    this.props.contacts.forEach((contact) => {
      rows.push(
        <ContactRow
          contact={contact}
          key={contact.id}
          onContactEditClick={this.props.onContactEditClick}
        />
      );
    });

    return (
      <table className="table">
        <thead>
          <tr>
            <th></th>
            <th>Name</th>
            <th>Phone</th>
            <th>Address</th>
            <th></th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}


class ContactForm extends Component {
  constructor(props) {
    super(props);

    this.state = {
      contact: props.contact
    };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.contact.id) {
      fetch(API_URL + '/contacts/' + nextProps.contact.id, { cache: 'reload', headers: HEADERS })
        .then(res => {
          let lastModified = res.headers.get('last-modified');
          let etag = res.headers.get('etag');

          this.setState({ contact: nextProps.contact, lastModified: lastModified, etag: etag });
        })

    } else {
      this.setState({ contact: nextProps.contact });
    }
  }

  handleChange(e) {
    let contact = this.state.contact;
    contact.attributes[e.target.name] = e.target.value;
    this.setState({ contact: contact });
  }

  handleSubmit(e) {
    e.preventDefault();

    let path = API_URL + '/contacts/';
    let method = 'POST';
    let body = {
      data: { attributes: this.state.contact.attributes }
    }

    if (this.state.contact.id) {
      path = path + this.state.contact.id;
      body.data.id = this.state.contact.id;
      method = 'PATCH';
    }

    HEADERS.set('If-None-Match', this.state.etag);
    HEADERS.set('If-Modified-Since', this.state.lastModified);

    fetch(path, {
      method: method,
      headers: HEADERS,
      body: JSON.stringify(body)
    }).then(res => {
        if (res.ok) {
          this.props.onContactFormSubmit();
        } else {
          console.error(res);
        }
      });
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <div className="form-group">
          <label>First Name</label>
          <input
            name="first_name"
            className="form-control"
            type="text"
            value={this.state.contact.attributes.first_name}
            onChange={this.handleChange}
          />
        </div>
        <div className="form-group">
          <label>Last Name</label>
          <input
            name="last_name"
            className="form-control"
            type="text"
            value={this.state.contact.attributes.last_name}
            onChange={this.handleChange}
          />
        </div>
        <div className="form-group">
          <label>Phone</label>
          <input
            name="phone"
            className="form-control"
            type="text"
            value={this.state.contact.attributes.phone}
            onChange={this.handleChange}
          />
        </div>
        <div className="form-group">
          <label>Address</label>
          <input
            name="address"
            className="form-control"
            type="text"
            value={this.state.contact.attributes.address}
            onChange={this.handleChange}
          />
        </div>
        <button className="btn btn-primary" type="submit">
          { this.state.contact.id ? 'Update' : 'Add' } contact
        </button>
      </form>
    );
  }
}

class SearchBar extends React.Component {
  constructor(props) {
    super(props);
    this.handleFilterTextChange = this.handleFilterTextChange.bind(this);
  }

  handleFilterTextChange(e) {
    this.props.onFilterTextChange(e.target.value);
  }

  render() {
    return (
      <form>
        <div className="form-group">
          <input
            className="form-control"
            type="text"
            placeholder="Search..."
            value={this.props.filterText}
            onChange={this.handleFilterTextChange}
          />
        </div>
      </form>
    );
  }
}

function build_contacts(json) {
  return json.data.map((contact) => {
    contact.attributes.first_name = contact.attributes.first_name || '';
    contact.attributes.last_name = contact.attributes.last_name || '';
    contact.attributes.phone = contact.attributes.phone || '';
    contact.attributes.address = contact.attributes.address || '';
    return contact;
  });
}

function fetch_contacts(query) {
  const q = query ? '?query=' + query : '';
  return fetch(API_URL + '/contacts'+ q, { headers: HEADERS })
           .then((response) => response.json())
           .then((json) => build_contacts(json))
           .catch((error) => {
             console.error(error);
             return [];
           });
}

class FilterableContactTable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filterText: '',
      data: [],
      editContact: {
        attributes: {
          first_name: '',
          last_name: '',
          phone: '',
          address: '',
        }
      }
    };

    fetch_contacts().then((data) => {
      this.setState({
        data: data
      })
    })

    this.handleFilterTextChange = this.handleFilterTextChange.bind(this);
    this.handleContactFormSubmit = this.handleContactFormSubmit.bind(this);
    this.handleContactEditClick = this.handleContactEditClick.bind(this);
  }

  handleFilterTextChange(filterText) {
    fetch_contacts(filterText).then((data) => {
      this.setState({ data: data })
    })

    this.setState({
      filterText: filterText
    });
  }

  handleContactFormSubmit() {
    fetch_contacts().then((data) => {
      this.setState({
        editContact: {
          attributes: {
            first_name: '',
            last_name: '',
            phone: '',
            address: '',
          }
        },
        data: data
      })
    })
  }

  handleContactEditClick(id) {
    let contact = this.state.data.find((element, index, array) => element.id === id);

    this.setState({
      editContact: contact
    })
  }

  render() {
    return (
      <div>
        <ContactForm
          contact={this.state.editContact}
          onContactFormSubmit={this.handleContactFormSubmit}
        />
        <hr/>
        <SearchBar
          filterText={this.state.filterText}
          onFilterTextChange={this.handleFilterTextChange}
        />
        <ContactTable
          contacts={this.state.data}
          onContactEditClick={this.handleContactEditClick}
        />
      </div>
    );
  }
}

class App extends Component {
  render() {
    return (
      <div className="App container">
        <FilterableContactTable />
      </div>
    );
  }
}

export default App;

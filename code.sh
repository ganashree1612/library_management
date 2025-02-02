#!/bin/bash

LIBRARY_FILE="library.csv"
AUTHOR_LOGIN_FILE="author_login.txt"
USER_LOGIN_FILE="user_login.txt"
BORROWED_BOOKS_FILE="borrowed_books.txt"

# Function to register a new author
register_author() {
    new_author_username=$(zenity --entry --title "Register New Author" --text "Enter new author username:" --width=400 --height=500)
    new_author_password=$(zenity --password --title "Register New Author" --text "Enter new author password:" --width=400 --height=500)

    echo "$new_author_username:$new_author_password" >> "$AUTHOR_LOGIN_FILE"
    zenity --info --text "New author registered successfully! 🎉" --width=400 --height=500
}

# Function to register a new user
register_user() {
    new_user_username=$(zenity --entry --title "Register New User" --text "Enter new user username:" --width=400 --height=500)
    new_user_password=$(zenity --password --title "Register New User" --text "Enter new user password:" --width=400 --height=500)

    echo "$new_user_username:$new_user_password" >> "$USER_LOGIN_FILE"
    zenity --info --text "New user registered successfully! 🎉" --width=400 --height=500
}

# Function to authenticate author using zenity
authenticate_author() {
    author_username=$(zenity --entry --title "Author Login" --text "Enter author username:" --width=400 --height=500)
    author_password=$(zenity --password --title "Author Login" --text "Enter author password:" --width=400 --height=500)

    if grep -q "^$author_username:$author_password$" "$AUTHOR_LOGIN_FILE"; then
        zenity --info --text "Author authentication successful! 🎉" --width=400 --height=500
    else
        zenity --error --text "Author authentication failed. Exiting... ❌" --width=400 --height=500
        exit 1
    fi
}

# Function to authenticate user using zenity
authenticate_user() {
    user_username=$(zenity --entry --title "User Login" --text "Enter user username:" --width=400 --height=500)
    user_password=$(zenity --password --title "User Login" --text "Enter user password:" --width=400 --height=500)

    if grep -q "^$user_username:$user_password$" "$USER_LOGIN_FILE"; then
        zenity --info --text "User authentication successful! 🎉" --width=400 --height=500
    else
        zenity --error --text "User authentication failed. Exiting... ❌" --width=400 --height=500
        exit 1
    fi
}

# Function to determine login type
select_login_type() {
    login_type=$(zenity --list --title "Login Type" --column "Select login type:" "Author" "User" "Register New User/Author" --width=400 --height=500)

    case $login_type in
        "Author") authenticate_author ;;
        "User") authenticate_user ;;
        "Register New User/Author") register_new_user_author ;;
        *) zenity --error --text "Invalid selection. Exiting... ❌" --width=400 --height=500; exit 1 ;;
    esac
}

# Function to register a new user or author
register_new_user_author() {
    registration_type=$(zenity --list --title "Registration Type" --column "Select registration type:" "Register New Author" "Register New User" --width=400 --height=500)

    case $registration_type in
        "Register New Author") register_author ;;
        "Register New User") register_user ;;
        *) zenity --error --text "Invalid selection. Exiting... ❌" --width=400 --height=500; exit 1 ;;
    esac
}

# Function to display the main menu
display_menu() {
    choice=$(zenity --list --title "Library Management System" --text "Choose an option:" \
        --column="Option" --column="Description" \
        "Add Book" "Add a new book to the library" \
        "View All Books" "View all books in the library" \
        "Search Books by Author" "Search books by author" \
        "Display All Authors" "Display all unique authors" \
        "Borrow Book" "Borrow a book from the library" \
        "Return Book" "Return a borrowed book" \
        "Count Books by Author" "Count the number of books by a specific author" \
        "Display Total Books" "Display the total number of books in the library" \
        "Edit Book" "Edit book information" \
        "Delete Book" "Delete a book from the library" \
        "Display Borrowed Books" "View books borrowed by the user" \
        "Exit" "Exit the program" --width=600 --height=500)

    case $choice in
        "Add Book") add_book ;;
        "View All Books") view_books ;;
        "Search Books by Author") search_books_by_author ;;
        "Display All Authors") display_authors ;;
        "Borrow Book") borrow_book ;;
        "Return Book") return_book ;;
        "Count Books by Author") count_books_by_author ;;
        "Display Total Books") display_total_books ;;
        "Edit Book") edit_book ;;
        "Delete Book") delete_book ;;
        "Display Borrowed Books") display_borrowed_books ;;
        "Exit") zenity --info --text "Exiting... 🚪" --width=400 --height=500; exit 0 ;;
        *) zenity --error --text "Invalid choice. Please try again. ❌" --width=400 --height=500 ;;
    esac
}
# Function to display borrowed books
display_borrowed_books() {
    if [ -s "$BORROWED_BOOKS_FILE" ]; then
        borrowed_books_info=$(cat "$BORROWED_BOOKS_FILE")
        zenity --text-info --title "Borrowed Books" --filename "$BORROWED_BOOKS_FILE" --width=600 --height=500
    else
        zenity --info --text "No books have been borrowed yet. 📚" --width=400 --height=500
    fi
}

# Function to delete a book
delete_book() {
    book_title=$(zenity --entry --title "Delete Book" --text "Enter the title of the book to delete:" --width=400 --height=500)

    # Check if the book exists in the library
    if grep -q "^$book_title" "$LIBRARY_FILE"; then
        # Remove the book from the library
        sed -i "/^$book_title,/d" "$LIBRARY_FILE"
        zenity --info --text "Book deleted successfully! 📚" --width=400 --height=500
    else
        zenity --error --text "Book not found in the library. Please check the title and try again. ❌" --width=400 --height=500
    fi
}
# Function to edit book information
edit_book() {
    book_title=$(zenity --entry --title "Edit Book" --text "Enter the title of the book to edit:" --width=400 --height=500)

    # Check if the book exists in the library
    if grep -q "^$book_title" "$LIBRARY_FILE"; then
        # Prompt for new information
        new_title=$(zenity --entry --title "Edit Book" --text "Enter new title:" --width=400 --height=500)
        new_author=$(zenity --entry --title "Edit Book" --text "Enter new author:" --width=400 --height=500)
        new_quantity=$(zenity --entry --title "Edit Book" --text "Enter new quantity:" --width=400 --height=500)

        # Update the book information
        sed -i "/^$book_title,/ s/^.*$/$new_title,$new_author,$new_quantity/" "$LIBRARY_FILE"
        zenity --info --text "Book information updated successfully! 📚" --width=400 --height=500
    else
        zenity --error --text "Book not found in the library. Please check the title and try again. ❌" --width=400 --height=500
    fi
}


# Function to add a book (only accessible to authors)
add_book() {
    # Check if the user is an author
    if ! grep -q "^$author_username" "$AUTHOR_LOGIN_FILE"; then
        zenity --error --text "Only authors can add books. Please log in as an author. ❌" --width=400 --height=500
        return
    fi

    title=$(zenity --entry --title "Add Book" --text "Enter book title:" --width=400 --height=500)
    quantity=$(zenity --entry --title "Add Book" --text "Enter the quantity of books to add:" --width=400 --height=500)

    # Validate if quantity is a positive integer
    if ! [[ "$quantity" =~ ^[1-9][0-9]*$ ]]; then
        zenity --error --text "Invalid quantity. Please enter a positive integer for the number of books. ❌" --width=400 --height=500
        return
    fi

    # Add the book entries to the library file
    for ((i=1; i<=$quantity; i++)); do
        echo "$title,$author_username" >> "$LIBRARY_FILE"
    done

    zenity --info --text "Books added successfully! 📚\nTotal Books Added: $quantity" --width=400 --height=500
}

# Function to view all books
view_books() {
    zenity --text-info --title "View All Books" --filename "$LIBRARY_FILE" --width=600 --height=500
}

# Function to search for books by author
search_books_by_author() {
    author=$(zenity --entry --title "Search Books by Author" --text "Enter author:" --width=400 --height=500)
    result=$(grep -i "$author" "$LIBRARY_FILE" | cut -d ',' -f 1)
    if [ -n "$result" ]; then
        zenity --info --title "Books by $author" --text "$(echo "$result" | tr '\n' ' ')" --width=600 --height=500
    else
        zenity --info --text "No books found for author $author. ❌" --width=400 --height=500
    fi
}

# Function to display unique authors
display_authors() {
    authors=$(cut -d ',' -f 2 "$LIBRARY_FILE" | sort | uniq)
    zenity --info --title "Unique Authors" --text "$(echo "$authors" | tr '\n' ' ')" --width=600 --height=500
}

# Function to count the number of books by a specific author
count_books_by_author() {
    author_to_count=$(zenity --entry --title "Count Books by Author" --text "Enter author's name:" --width=400 --height=500)
    count=$(grep -ic "$author_to_count" "$LIBRARY_FILE")

    if [ "$count" -gt 0 ]; then
        zenity --info --title "Books by $author_to_count" --text "Number of books: $count" --width=400 --height=500
    else
        zenity --info --text "No books found for author $author_to_count. ❌" --width=400 --height=500
    fi
}

# Function to display the total number of books in the library with tables
display_total_books() {
    total_books=$(wc -l < "$LIBRARY_FILE")
    zenity --info --title "Total Number of Books in the Library" --text "Total Books: $total_books" --width=400 --height=500
}

# Function to borrow a book
borrow_book() {
    # Check if the user is not an author
    if grep -q "^$user_username" "$AUTHOR_LOGIN_FILE"; then
        zenity --error --text "Authors cannot borrow books. Please log in as a user. ❌" --width=400 --height=500
        return
    fi

    book_title=$(zenity --entry --title "Borrow Book" --text "Enter the title of the book you want to borrow:" --width=400 --height=500)
    # Check if the book exists in the library
    if grep -q "^$book_title" "$LIBRARY_FILE"; then
        # Get current date
        current_date=$(date +"%Y-%m-%d")
        # Get the author's name
        author_name=$(grep "^$book_title," "$LIBRARY_FILE" | cut -d ',' -f 2)
        # Store borrowed book information with user and author
        echo "$book_title,$user_username,$author_name,$current_date" >> "$BORROWED_BOOKS_FILE"
        zenity --info --text "Book borrowed successfully! 📖\nDate of borrowing: $current_date" --width=400 --height=500
        # Remove the borrowed book from the library
        sed -i "/^$book_title/d" "$LIBRARY_FILE"
    else
        zenity --error --text "Book not found in the library. Please check the title and try again. ❌" --width=400 --height=500
    fi
}

# Function to return a borrowed book
# Function to return a borrowed book with possible fine calculation
return_book() {
    book_to_return=$(zenity --entry --title "Return Book" --text "Enter the title of the book to return:" --width=400 --height=500)

    # Check if the book is borrowed
    if grep -q "^$book_to_return" "$BORROWED_BOOKS_FILE"; then
        borrowed_info=$(grep "^$book_to_return" "$BORROWED_BOOKS_FILE")
        return_date=$(echo "$borrowed_info" | cut -d ',' -f 4)

        current_date=$(date +"%Y-%m-%d")
        days_diff=$(( ($(date -d "$current_date" +%s) - $(date -d "$return_date" +%s)) / (60*60*24) ))

        if [ "$days_diff" -gt 15 ]; then
            fine_amount=$(bc <<< "scale=2; $FINE_RATE * ($days_diff - 15)")
            zenity --info --text "Book returned successfully! 📚\nFine imposed: $fine_amount" --width=400 --height=500
        else
            zenity --info --text "Book returned successfully! 📚" --width=400 --height=500
        fi

        # Remove the book from borrowed list
        sed -i "/^$book_to_return/d" "$BORROWED_BOOKS_FILE"

        # Add the book back to the library with the author's name
        author_name=$(grep -i "^$book_to_return" "$LIBRARY_FILE" | cut -d ',' -f 2)
        echo "$book_to_return,$author_name" >> "$LIBRARY_FILE"
    else
        zenity --error --text "Book not found in borrowed books. Please check the title and try again. ❌" --width=400 --height=500
    fi
}


# Main program
select_login_type

while true; do
    display_menu
done


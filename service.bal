import ballerina/http;
import ballerina/persist;
import book_store.store;

final store:Client sClient = check new();

// Apply service-level CORS configuration
@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://bc70e030-36d3-4968-a241-e1d14a3748f9-dev.e1-us-cdp-2.choreoapis.dev/bookstore/bookstore-backend/v1"],
        allowCredentials: false,
        allowHeaders: ["Content-Type", "Authorization", "x-jwt-assertion"],
        exposeHeaders: ["Content-Length", "Content-Type"],
        maxAge: 3600
    }
}
service / on new http:Listener(9090) {

    resource function post books(store:BookRequest book) returns int|error {
        store:BookInsert bookInsert = check book.cloneWithType();
        int[] bookIds = check sClient->/books.post([bookInsert]);
        return bookIds[0];
    }

    resource function get books/[int id]() returns store:Book|error {
        return check sClient->/books/[id];
    }

    resource function get books() returns store:Book[]|error {
        stream<store:Book, persist:Error?> resultStream = sClient->/books;
        return check from store:Book book in resultStream
            select book;
    }

    resource function put books/[int id](store:BookUpdate book) returns store:Book|error {
        return check sClient->/books/[id].put(book);
    }

    resource function delete books/[int id]() returns store:Book|error {
        return check sClient->/books/[id].delete();
    }
}

# PBKeyValueKit

Various key/value persistence implementations with a common interface.

Each implementation provides a different storage mechanism:

- InMemoryKeyValueStore
    Uses an in memory dictionary to store values.

### Future Implementations:

- UserDefaultsKeyValueStore
   Backed by UserDefaults
   
- KeychainKeyValueStore
    Secure storage backed by Apples Keychain api

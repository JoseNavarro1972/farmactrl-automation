package cl.iplacex.farmactrl;

import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.*;

class SampleIntegrationIT {

    @TempDir
    static Path tmp;

    @Test
    @Tag("integration")
    void writesAndReadsInventoryFile() throws Exception {
        Path file = tmp.resolve("inventory.txt");
        Files.writeString(file, "paracetamol,100\nibuprofeno,50");

        assertTrue(Files.exists(file), "El archivo debería existir");
        String content = Files.readString(file);
        assertTrue(content.contains("paracetamol"));
        assertTrue(content.contains("ibuprofeno"));
    }
}

import java.io.*;

public class ReadClaims {

	public static void main(String[] args) {
		try {
			ProcessBuilder pb = new ProcessBuilder("./process_claims.exe");
			pb.redirectErrorStream(true);
			Process process = pb.start();
			process.waitFor();
			
			BufferedReader reader = new BufferedReader(new FileReader("processed_claims.txt"));

			String line;
			System.out.println("Processed claims:");
			while ((line = reader.readLine()) != null) {
				System.out.println(line);
			}
	
			reader.close();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}

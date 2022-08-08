import Foundation

import Gardener
import Version

// https://learn.adafruit.com/keep-your-circuitpython-libraries-on-devices-up-to-date-with-circup/
public class CircUp
{
    public init?()
    {
        guard checkPythonVersion() else
        {
            return nil
        }

        guard checkPipVersion() else
        {
            return nil
        }

        guard checkGitVersion() else
        {
            return nil
        }

        if !checkCircUpInstalled()
        {
            guard installCircUp() else
            {
                return nil
            }
        }
    }

    func checkPythonVersion() -> Bool
    {
        let command = Command()
        command.addPathFirst("/opt/homebrew/bin")

        guard let (_, result, _) = command.run("python3", "--version") else
        {
            print("Could not run python. Is python installed?")
            return false
        }
        guard let table = tabulate(string: result.string, headers: false, rowHeaders: true, oneSpaceAllowed: false) else
        {
            print("Could not tabulate data: \(result.string)")
            return false
        }

        guard let version = Version(table.rows[0].fields[0]) else
        {
            print("Bad python version string")
            return false
        }

        guard version.major >= 3 else
        {
            print("Python is too old: \(version)")
            return false
        }

        return true
    }

    func checkPipVersion() -> Bool
    {
        let command = Command()
        command.addPathFirst("/opt/homebrew/bin")

        guard let (_, result, _) = command.run("pip3", "--version") else
        {
            print("Could not run pip. Is pip installed?")
            return false
        }
        guard let table = tabulate(string: result.string, headers: false, rowHeaders: true, oneSpaceAllowed: false) else
        {
            print("Could not tabulate data: \(result.string)")
            return false
        }

        guard let version = Version(table.rows[0].fields[0]) else
        {
            print("Bad pip version string")
            return false
        }

        guard version.major >= 22 else
        {
            print("Pip is too old: \(version)")
            return false
        }

        return true
    }

    func checkGitVersion() -> Bool
    {
        let command = Command()
        command.addPathFirst("/opt/homebrew/bin")

        guard let (_, result, _) = command.run("git", "--version") else
        {
            print("Could not run git. Is pip installed?")
            return false
        }
        guard let table = tabulate(string: result.string, headers: false, rowHeaders: true, oneSpaceAllowed: false) else
        {
            print("Could not tabulate data: \(result.string)")
            return false
        }

        guard let version = Version(table.rows[0].fields[1]) else
        {
            print("Bad pip version string")
            return false
        }

        guard version.major >= 2 else
        {
            print("Pip is too old: \(version)")
            return false
        }

        return true
    }

    func checkCircUpInstalled() -> Bool
    {
        let command = Command()
        command.addPathFirst("/opt/homebrew/bin")

        guard let (_, result, _) = command.run("pip3", "list") else
        {
            print("Could not run pip3. Is pip3 installed?")
            return false
        }
        guard let table = tabulate(string: result.string, headers: false, rowHeaders: true, oneSpaceAllowed: false) else
        {
            print("Could not tabulate data: \(result.string)")
            return false
        }

        guard let index = table.findRowIndex(label: "circup") else
        {
            return false
        }

        let versionString = table.rows[index].fields[0]

        guard let version = Version(versionString) else
        {
            print("Bad circup version string")
            return false
        }

        guard version.major >= 1 else
        {
            print("CircUp is too old: \(version)")
            return false
        }

        return true
    }

    func installCircUp() -> Bool
    {
        let command = Command()
        command.addPathFirst("/opt/homebrew/bin")

        guard let (result, _, _) = command.run("pip3", "install", "circup") else
        {
            print("Could not run pip3. Is pip3 installed?")
            return false
        }

        return result == 0
    }

    public func install(_ library: String) throws
    {
        try self.run("install", library)
    }

    public func update(_ library: String) throws
    {
        try self.run("update", library)
    }

    public func updateAll() throws
    {
        try self.run("update", "--all")
    }

    public func run(_ args: String...) throws
    {
        try self.run(args)
    }

    public func run(_ args: [String]) throws
    {
        let command = Command()

        guard let _ = command.run("circup", args) else
        {
            throw CircUpError.commandFailed
        }
    }
}

public enum CircUpError: Error
{
    case commandFailed
}

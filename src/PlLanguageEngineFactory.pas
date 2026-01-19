unit PlLanguageEngineFactory;

{*******************************************************************************
 * MIT License
 *
 * Copyright (c) 2023-2025 Paolo Morandotti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *******************************************************************************}

{ ***************************************************************************
  /// Project: PlComponents
 /// Unit: PlLanguageEngineFactory
 /// This unit contains:
 /// - TPlLanguageEngineFactory: the Factory pattern based creator of engines
 **************************************************************************** }

interface

uses
  System.Generics.Collections,
  PlLanguageEngine, PlLanguageTypes;

type
  /// <summary>
  /// Metaclass reference for language engine implementations.
  /// </summary>
  /// <remarks>
  /// The referenced class must implement <see cref="IPlLanguageEngine"/>
  /// and expose a parameterless constructor.
  /// </remarks>
  TPlLanguageEngineClass = class of TPlLanguageEngine;

  /// <summary>
  /// Factory responsible for registering and instantiating language engines.
  /// </summary>
  /// <remarks>
  /// <para>
  /// The factory decouples engine creation from concrete implementations.
  /// Custom engines can be registered at application startup (typically
  /// in the <c>initialization</c> section of the engine unit).
  /// </para>
  /// <para>
  /// Engines are identified by <see cref="TPlLanguagePersistence"/> values.
  /// </para>
  /// </remarks>
  TPlLanguageEngineFactory = class
  private
    /// <summary>
    /// Internal registry mapping persistence styles to engine classes.
    /// </summary>
    class var FRegister:
      TDictionary<TPlLanguagePersistence, TPlLanguageEngineClass>;
  protected
    /// <summary>
    /// Initializes the internal engine registry.
    /// </summary>
    class constructor Create;

    /// <summary>
    /// Finalizes the internal engine registry.
    /// </summary>
    class destructor Destroy;
  public
    /// <summary>
    /// Creates a language engine instance for the given persistence type.
    /// </summary>
    /// <param name="AnEngineType">
    /// The persistence style associated with the requested engine.
    /// </param>
    /// <returns>
    /// An instance implementing <see cref="IPlLanguageEngine"/>.
    /// </returns>
    /// <exception cref="EPlLanguageException">
    /// Raised if no engine is registered for the specified persistence type.
    /// </exception>
    class function CreateEngine(
      const AnEngineType: TPlLanguagePersistence): IPlLanguageEngine;

    /// <summary>
    /// Registers a language engine class for a given persistence type.
    /// </summary>
    /// <param name="AnEngineType">
    /// The persistence style implemented by the engine.
    /// </param>
    /// <param name="AnEngineClass">
    /// The engine class to register.
    /// </param>
    /// <remarks>
    /// <para>
    /// Although engine classes are constrained to inherit from TPlLanguageEngine,
    /// a runtime instantiation test is performed to:
    /// - ensure the constructor is accessible and side-effect free
    /// - fail fast during registration rather than at engine creation time
    /// </para>
    /// <para>
    /// If an engine is already registered for the specified persistence type,
    /// the call is ignored.
    /// </para>
    /// </remarks>
    /// <exception cref="EPlLanguageException">
    /// Raised if the provided class does not implement
    /// <see cref="IPlLanguageEngine"/>.
    /// </exception>
    class procedure Register(
      const AnEngineType: TPlLanguagePersistence;
      AnEngineClass: TPlLanguageEngineClass);

    /// <summary>
    /// Unregisters the engine associated with a given persistence type.
    /// </summary>
    /// <param name="AnEngineType">
    /// The persistence style whose engine registration should be removed.
    /// </param>
    /// <remarks>
    /// Calling this method for a non-registered persistence type has no effect.
    /// </remarks>
    class procedure Unregister(
      const AnEngineType: TPlLanguagePersistence);
  end;

implementation

uses
  System.SysUtils;

{$REGION 'TPlLanguageEngineFactory'}

class constructor TPlLanguageEngineFactory.Create;
begin
  FRegister :=
    TDictionary<TPlLanguagePersistence, TPlLanguageEngineClass>.Create;
end;

class destructor TPlLanguageEngineFactory.Destroy;
begin
  FRegister.Free;
end;

class function TPlLanguageEngineFactory.CreateEngine(
  const AnEngineType: TPlLanguagePersistence): IPlLanguageEngine;
var
  EngineClass: TPlLanguageEngineClass;
begin
  if FRegister.TryGetValue(AnEngineType, EngineClass) then
    Result := EngineClass.Create as IPlLanguageEngine
  else
    raise EPlLanguageException.Create(SEngineNotImplemented);
end;

class procedure TPlLanguageEngineFactory.Register(
  const AnEngineType: TPlLanguagePersistence;
  AnEngineClass: TPlLanguageEngineClass);
var
  Test: IPlLanguageEngine;
begin
  try
    Test := AnEngineClass.Create as IPlLanguageEngine;
  except
    on E: Exception do
      raise EPlLanguageException.CreateFmt(
        STheClassDontImplementIPlLanguage,
        [AnEngineClass.ClassName]
      );
  end;

  if not FRegister.ContainsKey(AnEngineType) then
    FRegister.Add(AnEngineType, AnEngineClass);
end;

class procedure TPlLanguageEngineFactory.Unregister(
  const AnEngineType: TPlLanguagePersistence);
begin
  FRegister.Remove(AnEngineType);
end;

{$ENDREGION}

end.


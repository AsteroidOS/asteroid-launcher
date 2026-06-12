/***************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** Copyright (C) 2012 Jolla Ltd.
** Contact: Robin Burchell <robin.burchell@jollamobile.com>
**
** This file is part of lipstick.
**
** This library is free software; you can redistribute it and/or
** modify it under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation
** and appearing in the file LICENSE.LGPL included in the packaging
** of this file.
**
****************************************************************************/

#ifndef CATEGORYDEFINITIONSTORE_H_
#define CATEGORYDEFINITIONSTORE_H_

#include <QString>
#include <QMap>
#include <QSet>
#include <QSettings>
#include <QSharedPointer>
#include <QStringList>
#include <QFileSystemWatcher>

/*!
 * A class that represents a notification category store. The category
 * store will store all the category definitions stored in the given path.
 *
 * The category store will limit the number of configuration
 * files it will read. The rationale is to constrain memory usage and startup
 * time in case a huge number of category definitions are defined by a misbehaving
 * package.
 */
class CategoryDefinitionStore : public QObject
{
    Q_OBJECT

public:
    /*!
     * Creates a notification category definitions store.
     *
     * \param categoryDefinitionsPath The path where the different category definitions are defined
     * \param maxStoredCategoryDefinitions The maximum number of category definitions to keep in memory
     */
    explicit CategoryDefinitionStore(const QString &categoryDefinitionsPath, uint maxStoredCategoryDefinitions = 100, QObject *parent = 0);

    /*!
     * Tests if the \a category definition exists in the system.
     * Loads the category definition if it exists.
     *
     * \param category the category to check.
     * \return \c true if the category exists, \c false otherwise.
     */
    bool categoryDefinitionExists(const QString &category) const;

    /*!
     * Returns all parameter keys for a given category definition. If the category doesn't
     * exist, an empty list is returned.
     *
     * \param category the category.
     * \sa categoryExists, contains, value
     */
    QList<QString> allKeys(const QString &category) const;

    /*!
     * Check if a given parameter \a key exists in the the definition for \a category.
     * If the \a key does exist in the \a category, this method returns \c true. If the
     * \a key does not exist or the \a category does not exist at all, this method returns
     * \c false.
     *
     * \param category the category.
     * \param key the parameter key.
     * \return \c true if the key exists in the category, \c false otherwise.
     * \sa categoryDefinitionExists, allKeys, value
     */
    bool contains(const QString &category, const QString &key) const;

    /*!
     * Returns the value for the given parameter \a key in the definition for \a category.
     * If the \a key does not exist in the \a category or the \a categorydoes not exist at all,
     * this method returns an empty string.
     *
     * \param category the category.
     * \param key the parameter key.
     * \return the value for the key in the category.
     * \sa categoryExists, allKeys, contains
     */
    QString value(const QString &category, const QString &key) const;

    /*!
     * Returns all parameters for a given category definition. If the category doesn't
     * exist, an empty hash is returned.
     *
     * \param category the category.
     * \sa categoryExists, allKeys, value
     */
    QHash<QString, QString> categoryParameters(const QString &category) const;

private slots:
    //! Updates the list of available category definition files
    void updateCategoryDefinitionFileList();

    /*!
     * Updates the category definition represented in the given file
     *
     * Only updates the category definition if the file is modified. Removing an category definition file is handled
     * by updateCategoryDefinitionFileList() slot
     */
    void updateCategoryDefinitionFile(const QString &path);

signals:
    /*!
     * A signal sent whenever an category definition has been modified
     *
     * \param category the category definition that was modified
     */
    void categoryDefinitionModified(const QString &category);

    /*!
     * A signal sent whenever an category definition has been uninstalled
     *
     * \param category the category definition that was removed
     */
    void categoryDefinitionUninstalled(const QString &category);

private:
    //! The path where the category definition files are stored
    QString categoryDefinitionsPath;

    //! The maximum number of category definitions to keep in memory
    uint maxStoredCategoryDefinitions;

    //! Map for storing category definitions and corresponding QSettings object
    mutable QMap<QString, QSharedPointer<QSettings> > categoryDefinitions;

    //! List for keeping track of which category definitions have been most recently used
    mutable QStringList categoryDefinitionUsage;

    //! Load the data into our internal map
    void loadSettings(const QString &category) const;

    //! Marks the category to be used recently
    void categoryDefinitionAccessed(const QString &category) const;

    //! File system watcher to notice changes in installed category definitions
    QFileSystemWatcher categoryDefinitionPathWatcher;

    //! List of available category definition files
    QSet<QString> categoryDefinitionFiles;
};

#endif /* CATEGORYDEFINITIONSTORE_H_ */
